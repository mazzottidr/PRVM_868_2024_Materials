# PRVM 868 - Biomedical Informatics Driven Clinical Research
# Instructor: Diego R. Mazzotti, Ph.D.
# University of Kansas Medical Center

# Install any non-available package using the notation:
# install.packages("nameofpackage")

# Load packages we will use
library(dplyr)
library(caret)
library(pROC)
library(PRROC)
library(party)
library(randomForest)
library(jtools)

# If you are starting a new R session, make sure you are in the correct working directory
setwd("~/class")

# And make sure you load the analysis ready dataset we created last time
analysis_data_binge_bmi <- read.csv("analysis_data_binge_bmi.csv", stringsAsFactors = F)


# Let's remove the variable race, since it requires additional processing, and it is often good practice to not use race as a predictor in ML
ml_binge_dataset <- analysis_data_binge_bmi %>%
        select(-race)

# Some ML packages require categorical variables to  be represented as factors explicitly
ml_binge_dataset$binge_diag <- as.factor(ml_binge_dataset$binge_diag)
ml_binge_dataset$sex <- as.factor(ml_binge_dataset$sex)

# The question we would like to address is whether we can develop a prediction model that calculates the probability of someone having a diagnosis of BE disorder given their age, sex and BMI.

# We can actually do that with a logistic regression model. Let's run this first:
fit_reg1<-glm(binge_diag ~ baseline_bmi + baseline_age + sex, data=ml_binge_dataset, family=binomial())
summary(fit_reg1)
summ(fit_reg1)

# Can calculate the AUC for this model:
fit_reg1_roc <- pROC::roc(ml_binge_dataset$binge_diag,fit_reg1$fitted.values, levels = c("No", "Yes"))

# Now we will run other supervised ML models

## Decision Tree

# Decision tree algorithm falls under the category of supervised learning. They can be used to solve both regression and classification problems. Decision tree uses the tree representation to solve the problem in which each leaf node corresponds to a class label and attributes are represented on the internal node of the tree.

# Let's first clarify some terms used with decision trees:

# **Root Node**: It represents entire population or sample and this further gets divided into two or more homogeneous sets
# **Splitting**: It is a process of dividing a node into two or more sub-nodes
# **Decision/Internal Node**: When a sub-node splits into further sub-nodes, then it is called decision/internal node
# **Terminal/Leaf Node**: Nodes do not split is called Leaf or Terminal node
# **Branch/Sub-Tree**: A sub section of entire tree is called branch or sub-tree
# **Parent and Child Node**: A node, which is divided into sub-nodes is called parent node of sub-nodes where as sub-nodes are the child of parent node

fit_tree <- ctree(binge_diag ~ baseline_bmi + baseline_age + sex, data=ml_binge_dataset)
plot(fit_tree)

# Each decision notes usually show:       
#         
#       * splitting variable        
#       * splitting criteria      
# 
# Each terminal notes usually show:       
#         
# * number of training samples ended up in the node       
# * distribution of the predicted class (0 = no Binge Eating; 1 = Binge Eating)        

# We can extract the predictons:
pred_tree <- sapply(predict(fit_tree, newdata=ml_binge_dataset,type="prob"), "[[", 2)
fit_tree_roc <- pROC::roc(ml_binge_dataset$binge_diag,pred_tree)



#Let's compare the curves:
pROC::ggroc(list(Logistic_Regression=fit_reg1_roc,
                 Decision_Tree=fit_tree_roc))+
        geom_abline(intercept=1,linetype=2)+
        labs(subtitle = paste0("Logistic Regression AUC:",round(fit_reg1_roc$auc,4),"\n",
                               "Decision-Tree AUC:",round(fit_tree_roc$auc,4)))



# Now, let's introduce a new model - Random Forests:

##Random Forest

# Random Forests are ensembles of multiple decision trees. An ensemble is simply a collection of models trained on the same task. An ensemble of different models that all achieve similar generalization performance often outperforms any of the individual models.

# Because of its complexity, we might need to define "hyperparameters", or settings in the model that would make it work best for your data

# Let's try a few different settings, changing the number of trees we use (10, 50 or 200). Note that the model definition is the same
fit_rf10 <- randomForest(binge_diag ~ baseline_bmi + baseline_age + sex, 
                       data=ml_binge_dataset,ntree = 10, keep.forest = T, proximity = T, importance=T)
fit_rf50 <- randomForest(binge_diag ~ baseline_bmi + baseline_age + sex, 
                       data=ml_binge_dataset,ntree = 50, keep.forest = T, proximity = T, importance=T)
fit_rf200 <- randomForest(binge_diag ~ baseline_bmi + baseline_age + sex, 
                        data=ml_binge_dataset,ntree = 200, keep.forest = T, proximity = T, importance=T)

# Let's calculate predictions and ROC curves for each
rf10_pred <- predict(fit_rf10, newdata=ml_binge_dataset,type="prob")[,2]
fit_rf10_roc <- pROC::roc(ml_binge_dataset$binge_diag,rf10_pred)

rf50_pred <- predict(fit_rf50, newdata=ml_binge_dataset,type="prob")[,2]
fit_rf50_roc <- pROC::roc(ml_binge_dataset$binge_diag,rf50_pred)

rf200_pred <- predict(fit_rf200, newdata=ml_binge_dataset,type="prob")[,2]
fit_rf200_roc <- pROC::roc(ml_binge_dataset$binge_diag,rf200_pred)

# Now let's compare all models we created so far
pROC::ggroc(list(Logistic_regression=fit_reg1_roc,
                 Decision_Tree=fit_tree_roc,
                 Random_Forest10=fit_rf10_roc,
                 Random_Forest50=fit_rf50_roc,
                 Random_Forest200=fit_rf200_roc))+
        geom_abline(intercept=1,linetype=2)+
        labs(subtitle = paste0("Logistic Regression AUC:",round(fit_reg1_roc$auc,4),"\n",
                               "Decision-Tree AUC:",round(fit_tree_roc$auc,4),"\n",
                               "Random-Forest (10 trees) AUC:",round(fit_rf10_roc$auc,4),"\n",
                               "Random-Forest (50 trees) AUC:",round(fit_rf50_roc$auc,4),"\n",
                               "Random-Forest (200 trees) AUC:",round(fit_rf200_roc$auc,4)
        ))


# With random forests, we can calculate easily what variables were the most important for the prediction on average for all trees:

# Variable Importance Ranking
varImpPlot(fit_rf200)

# * Mean Decrease Accuracy: Mean Decrease in Accuracy is the average decrease in accuracy from not including the variable
# * Mean Decrease in Accuracy can provide low importance to other correlated features if one of them is given high importance       
# 
# * Mean Decrease Gini: Mean Decrease in Gini is the total decrease in node impurities from splitting on the variable, averaged over all trees         
# * Mean Decrease Gini can be biased towards categorical features which contain many categories   



## Model Validation

## Validation is a commonly-adopted approach to fairly evaluate how well your model fit within a research dataset ("internal validation") and generalize to other datasets ("external validation"). In practice, there are several approaches to perform validations:
        
# * Hold-out sets (e.g. 70% training, 30% testing)
# * Leave-one-out
# * k-fold cross validation

# In this demonstration, I will show the first approach (Hold-out), while the implementation of the other two approaches can be extended from the first approach.

# From the original dataset, let's create a training and testing sample

set.seed(100) # this is is used to ensure the results will be the same for everyone
train_ind <- sample(c(TRUE,FALSE),size=nrow(ml_binge_dataset),c(0.7,0.3),replace=T)
train <- filter(ml_binge_dataset, train_ind)
test <- filter(ml_binge_dataset, !train_ind)

# how many patients in each dataset?
nrow(train)
nrow(test)

# Let's re-train and independently test all the models we created

#########################
#### Logistic Regression
#########################

fit_reg1_train <- glm(binge_diag ~ baseline_bmi + baseline_age + sex, data=train, family=binomial()) # now data is train

# Performance on training set
fit_reg1_roc_train <- pROC::roc(train$binge_diag,fit_reg1_train$fitted.values, levels = c("No", "Yes"))

# Performance on testing set
fit_reg1_roc_test <- pROC::roc(test$binge_diag, predict(fit_reg1_train,newdata = test,type="response"))

# Plot
pROC::ggroc(list(Regression_tr=fit_reg1_roc_train,
                 Regression_ts=fit_reg1_roc_test))+
  geom_abline(intercept=1,linetype=2)+
  labs(subtitle = paste0("Logistic Regression Training AUC:",round(fit_reg1_roc_train$auc,4),"\n",
                         "Logistic Regression Testing AUC:",round(fit_reg1_roc_test$auc,4),"\n"))


##################
#### Decision Tree
##################
fit_tree_train <- ctree(binge_diag ~ baseline_bmi + baseline_age + sex, data=train)
pred_tree_train <- sapply(predict(fit_tree_train, newdata=train, type="prob"), "[[", 2)

# Performance on training set
fit_tree_roc_train <- pROC::roc(train$binge_diag, pred_tree_train)

# Performance on testing set
pred_tree_test <- sapply(predict(fit_tree_train, newdata=test, type="prob"), "[[", 2)
fit_tree_roc_test <- pROC::roc(test$binge_diag, pred_tree_test)

# Plot
pROC::ggroc(list(DecisionTree_tr=fit_tree_roc_train,
                 DecisionTree_ts=fit_tree_roc_test))+
        geom_abline(intercept=1,linetype=2)+
        labs(subtitle = paste0("Decision Tree Training AUC:",round(fit_tree_roc_train$auc,4),"\n",
                               "Decision Tree Testing AUC:",round(fit_tree_roc_test$auc,4),"\n"))


##############################
#### Random Forest (200 trees)
##############################
fit_rf200_train <- randomForest(binge_diag ~ baseline_bmi + baseline_age + sex, 
                          data=train, ntree = 200, keep.forest = T, proximity = T, importance=T)
rf200_pred_train <- predict(fit_rf200_train, newdata=train,type="prob")[,2]

# Performance of training set
fit_rf200_roc_train <- pROC::roc(train$binge_diag, rf200_pred_train)

# Performance of testing set
rf200_pred_test <- predict(fit_rf200_train, newdata=test,type="prob")[,2]
fit_rf200_roc_test <- pROC::roc(test$binge_diag, rf200_pred_test)

# Plot
pROC::ggroc(list(Regression1_tr=fit_rf200_roc_train,
                 Regression1_ts=fit_rf200_roc_test))+
        geom_abline(intercept=1,linetype=2)+
        labs(subtitle = paste0("Decision Tree Training AUC:",round(fit_rf200_roc_train$auc,4),"\n",
                               "Decision Tree Testing AUC:",round(fit_rf200_roc_test$auc,4),"\n"))


# Now, let's compare the testing results among the 3 models:
pROC::ggroc(list(Regression=fit_reg1_roc_test,
                 Decision_Tree=fit_tree_roc_test,
                 Random_Forest200=fit_rf200_roc_test))+
  geom_abline(intercept=1,linetype=2)+
  labs(subtitle = paste0("Logistic Regression Testing AUC:",round(fit_reg1_roc_test$auc,4),"\n",
                         "Decision-Tree Testing AUC:",round(fit_tree_roc_test$auc,4),"\n",
                         "Random-Forest (200 trees) Testing AUC:",round(fit_rf200_roc_test$auc,4)))

