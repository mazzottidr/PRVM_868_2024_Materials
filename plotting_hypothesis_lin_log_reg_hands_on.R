# PRVM 868 - Biomedical Informatics Driven Clinical Research
# Instructor: Diego R. Mazzotti, Ph.D.
# University of Kansas Medical Center

# If you are starting a new R session, make sure you are in the correct working directory
setwd("~/class")

# And make sure you load the data - we will use our dataset created last time
full_data_binge_bmi <- read.csv("full_data_binge_bmi.csv", stringsAsFactors = F)

# We will use the package dplyr too
library(dplyr)


#########
#
# Plots and exploratory data analysis
#
#########


# Quick and simple base plots

# Base R already comes with some plotting functionality

# For continuous variables, histogram, boxplots
hist(full_data_binge_bmi$age)
boxplot(full_data_binge_bmi$age)

hist(full_data_binge_bmi$median_bmi)
boxplot(full_data_binge_bmi$median_bmi)

#These are very limited, but for quick exploration could be useful

# One of the most powerful plotting frameworks in R is from ggplot2

# Let's load the package (or install if not installed already)
library(ggplot2)

# histograms
ggplot(full_data_binge_bmi, aes(x = age)) +
        geom_histogram()

# boxplots -  single variable
ggplot(full_data_binge_bmi, aes(y = age)) +
        geom_boxplot()

# boxplots - by group
ggplot(full_data_binge_bmi, aes(x=sex, y = age)) +
        geom_boxplot()

ggplot(full_data_binge_bmi, aes(x=sex, y = median_bmi)) +
        geom_boxplot()

# Bar plots - for counts of categorical variables
ggplot(data=full_data_binge_bmi, aes(x=sex)) +
        geom_bar(stat="count")

# Bar plots - for proportions
ggplot(full_data_binge_bmi, aes(x = sex)) +  
        geom_bar(aes(y = (..count..)/sum(..count..)))

# Point range plots, for continuous variables

# These are useful to plot mean and standard deviation of a continuous variable by groups of a categorical variable

# First, we need to create a data frame that contains these summaries by groups:
bmi_by_sex <- full_data_binge_bmi %>%
        group_by(sex) %>%
        summarise(n=n(),
                  mean_bmi=mean(median_bmi, na.rm = T),  ### the argument na.rm=T will remove observations with mising median_bmi (otherwise the unction will return NA)
                  sd_bmi=sd(median_bmi, na.rm = T))

# Let's see if this worked
bmi_by_sex

# Now, we use this new data frame to create the plot using ggplot
ggplot(data=bmi_by_sex, aes(x=sex, y=mean_bmi, group=sex)) +
        geom_point()+
        geom_errorbar(aes(ymin=mean_bmi-sd_bmi, ymax=mean_bmi+sd_bmi),
                      width=.2, position=position_dodge(0.05)) # These arguments are helpful to determine properties of the plot

# scatter plots
ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi)) +
        geom_point()

# Facets - can be useful to break down a plot into groups of a categorical variable.
# For example, let's create a scatter plot of age and bmi, by sex
ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi)) +
        geom_point() +
        facet_wrap(~ sex)

# Editing plot settings - we can improve the way the plot looks by changing setting such as

# Axes labels
ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi)) +
        geom_point() +
        facet_wrap(~ sex) +
        xlab("Age (in years)") + # Changes label of x axis
        ylab("Median BMI (kg/sq. meters)") # Changes label of y axis

# Colors
ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi, color=sex)) + # add color argment to aes()
        geom_point() +
        facet_wrap(~ sex) +
        xlab("Age (in years)") +
        ylab("Median BMI (kg/sq. meters)")

# You can select your own colors:
ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi, color=sex)) +
        geom_point() +
        facet_wrap(~ sex) +
        xlab("Age (in years)") +
        ylab("Median BMI (kg/sq. meters)") +
        scale_color_manual(values = c("darkgreen", "darkred"))

# Themes - sometimes, default theme is not appealing, you can try different options:
ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi, color=sex)) +
        geom_point() +
        facet_wrap(~ sex) +
        xlab("Age (in years)") +
        ylab("Median BMI (kg/sq. meters)") +
        scale_color_manual(values = c("darkgreen", "darkred")) +
        theme_bw()

ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi, color=sex)) +
        geom_point() +
        facet_wrap(~ sex) +
        xlab("Age (in years)") +
        ylab("Median BMI (kg/sq. meters)") +
        scale_color_manual(values = c("darkgreen", "darkred")) +
        theme_minimal()

ggplot(full_data_binge_bmi, aes(x = age, y=median_bmi, color=sex)) +
        geom_point() +
        facet_wrap(~ sex) +
        xlab("Age (in years)") +
        ylab("Median BMI (kg/sq. meters)") +
        scale_color_manual(values = c("darkgreen", "darkred")) +
        theme_classic()


####### Extra materials for plotting and exploratory data analysis

# An excellent resource to remind you how to do certain plots using ggplot is the Cookbook for R (http://www.cookbook-r.com/Graphs/)

# There are some packages that automate some exploratory data analysis steps.
# A recent blog post explore some recent packages: https://yuzar-blog.netlify.app/posts/2021-01-09-exploratory-data-analysis-and-beyond-in-r-in-progress/
# This is a long post, but has several examples of exploratory data analyses that you could explore and use in your own project.


#####################
## Real Data Cleaning
#####################

# Using our data, let's assess whether there is an association between diagnosis Binge eating disorder and BMI?

###### First, we need to make sure out data is clean and ready for analysis
###### Clean (tidy) data usually refers to:
        # The variables relevant for our study are create and available
        # Outliers are dealt with
        # Any missing data for our exposures / outcomes are dealt with
        # Factors of categorical data are named correctly

# Let's look at our data first. Can we find our exposure and outcome?

# Creating out Binge eating disorder diagnosis (Yes/No)
# The function ifelse helps with this task:
full_data_binge_bmi <- full_data_binge_bmi %>%
        mutate(binge_diag=ifelse(binge_count>=0, "Yes"))

# The missing values should all be "No", because missing data in this case means that these patients did not have a record of binge disorder in our initial dataset. Let's fix this:

# Using square bracket to select only the observations that are missing (e.g., TRUE for the function is.na()), and replacing with "No"
full_data_binge_bmi$binge_diag[is.na(full_data_binge_bmi$binge_diag)] <- "No"

# Let's make sure this is represented as factor
full_data_binge_bmi$binge_diag <- as.factor(full_data_binge_bmi$binge_diag)

# Let's check how many yes and nos we have:
table(full_data_binge_bmi$binge_diag)

# Now, we need to make sure we have our BMI variable available. We have several BMI variables - median, earliest, latest. Ideally, we would need to collect the BMI at the earliest diagnosis of binge eating (for those with diagnosis) and the latest BMI of those without a diagnosis (reflecting their more recent BMI, assuming they were not diagnosed with Binge Eating Disorder). Please not that this is just one example of design.

# For this, we will need to use our raw data ("sample_data.csv"), that contains dates for all events.

# Let's load it again in case we don't have it have it:

sample_data <-  read.csv("sample-data.csv", stringsAsFactors = F)


# For each patient separately, we need to find the BMI at the earliest diagnosis of Binge eating disorder.

#Let's create a data frame with this information first
binge_earliest_df <- sample_data %>%
        filter(variable=="Binge eating disorder") %>%
        group_by(patient_num) %>%
        summarise(earliest_binge_date=min(start_date))


# Now let's create another data frame with the information on BMI, including all BMI measures and dates of each measurement.
# Let's also rename some columns to make it easier when we merge the tables
all_bmi_df <- sample_data %>%
        filter(variable=="Body Mass Index") %>%
        select(patient_num, variable, nval, start_date) %>%
        rename(bmi=nval, bmi_start_date=start_date) %>%
        arrange(patient_num, bmi_start_date) # Let's also arrange by patient_num and date to make it easier to see all dates

# Since there might be some patients that may have 2 distinct BMI values at the same date, let's just get the first BMI (this happens very often!)
all_bmi_df <- all_bmi_df %>%
        group_by(patient_num,bmi_start_date) %>%
        mutate(counter_same_day=1:n()) %>% # This will create a counter (1 to the number of available dates in that patient)
        filter(counter_same_day==1) %>% # This will now select only the 1s, which represents the first measurement of each day
        select(-counter_same_day) # this will get rid of the counter column


#Let's now join these tables, so that we can compare the earliest_binge_date with the bmi_start_date. We can also remove from this table those that do not have binge diagnosis (missing to earliest_binge_date)
all_bmi_bing_earliest_df <- all_bmi_df %>%
        left_join(binge_earliest_df, by = c("patient_num"="patient_num")) %>%
        filter(!is.na(earliest_binge_date))  # remove patients without binge (missing to earliest_binge_date)

View(all_bmi_bing_earliest_df)

# Next, to help identifying what is the closest date, let's calculate the difference in days between the earliest_binge_date and all bmi_start_date. The ones closest to zero for each patient should be the date we get for the BMI measurement

# Let's load lubridate
library(lubridate)
all_bmi_bing_earliest_df <- all_bmi_bing_earliest_df %>%
        mutate(days_from_binge_to_bmi=floor(interval(earliest_binge_date, bmi_start_date) / days(1)))

# Now we just need to find, for each patient, what is the bmi_start_date that is closest to zero. One way of doing this is to finding the date that represents the minimum absolute value of days_from_binge_to_bmi
bmi_at_earliest_bing_df <- all_bmi_bing_earliest_df %>%
        mutate(abs_days_from_binge_to_bmi=abs(days_from_binge_to_bmi)) %>%
        group_by(patient_num) %>%
        summarise(earliest_binge_date=earliest_binge_date[abs_days_from_binge_to_bmi==min(abs_days_from_binge_to_bmi)],
                  bmi_date_at_earliest_binge=bmi_start_date [abs_days_from_binge_to_bmi==min(abs_days_from_binge_to_bmi)],
                  bmi_at_earliest_binge=bmi[abs_days_from_binge_to_bmi==min(abs_days_from_binge_to_bmi)],
                  days_from_binge_to_bmi=days_from_binge_to_bmi[abs_days_from_binge_to_bmi==min(abs_days_from_binge_to_bmi)])


# We can now finally merge this table with our full_data_binge_bmi
full_data_binge_bmi <- full_data_binge_bmi %>%
        left_join(bmi_at_earliest_bing_df, by = c("patient_num"="patient_num"))

# We are almost done creating our exposure and outcome. We just need to create a new BMI variable that contains the latest BMI of those without a diagnosis of Binge eating disorder and the BMI at bmi_at_earliest_binge for those that do.
full_data_binge_bmi <- full_data_binge_bmi %>%
        mutate(baseline_bmi=ifelse(binge_diag=="No", yes = latest_bmi, no = bmi_at_earliest_binge))

# Since age is a relevant variable, we shoul do the same thing (age at baseline)
full_data_binge_bmi <- full_data_binge_bmi %>%
        mutate(baseline_age=ifelse(binge_diag=="No", yes = age, no = age_at_first_binge))

# Some quality control - we want to make sure we include only participants that had a baseline_bmi value within 45 days_from_binge_to_bmi
full_data_binge_bmi_clean <- full_data_binge_bmi %>%
        filter(is.na(days_from_binge_to_bmi) | abs(days_from_binge_to_bmi)<45)

# At this point we can create a smaller data frame containing only the columns relevant for our analysis, with no missing data
analysis_data_binge_bmi <- full_data_binge_bmi_clean %>%
        select(patient_num, binge_diag,  baseline_bmi, baseline_age, sex, race) %>%
        tidyr::drop_na() # this uses a function from the tidyr package (drop_na()) and keeps only rows without missing data

# And now we can save this as a .csv file, so we can load it for future analyses
write.csv(analysis_data_binge_bmi, "analysis_data_binge_bmi.csv", row.names = F)



#####################
## Hypothesis testing
#####################

# Now that we have our dataset put together, let's calculate some descriptive statistics for the whole sample
analysis_data_binge_bmi %>%
        summarise(n=n(),
                mean_age=mean(baseline_age),
                sd_age=sd(baseline_age),
                min_age=min(baseline_age),
                max_age=max(baseline_age),
                mean_bmi=mean(baseline_bmi),
                sd_bmi=sd(baseline_bmi),
                min_bmi=min(baseline_bmi),
                max_bmi=max(baseline_bmi))

# It looks like there are very high values of BMI - let's remove any bmi greater than 200
analysis_data_binge_bmi <- analysis_data_binge_bmi %>%
        filter(baseline_bmi<200)

# Summary again:
analysis_data_binge_bmi %>%
        summarise(n=n(),
                  mean_age=mean(baseline_age),
                  sd_age=sd(baseline_age),
                  min_age=min(baseline_age),
                  max_age=max(baseline_age),
                  mean_bmi=mean(baseline_bmi),
                  sd_bmi=sd(baseline_bmi),
                  min_bmi=min(baseline_bmi),
                  max_bmi=max(baseline_bmi))


# Now, summary by binge eating disorder group
analysis_data_binge_bmi %>%
        group_by(binge_diag) %>%
        summarise(n=n(),
                  mean_age=mean(baseline_age),
                  sd_age=sd(baseline_age),
                  min_age=min(baseline_age),
                  max_age=max(baseline_age),
                  mean_bmi=mean(baseline_bmi),
                  sd_bmi=sd(baseline_bmi),
                  min_bmi=min(baseline_bmi),
                  max_bmi=max(baseline_bmi))


# Let's create a boxplot illustrating this
# boxplots - by group
ggplot(analysis_data_binge_bmi, aes(x=binge_diag, y = baseline_bmi)) +
        geom_boxplot()


# Let's use a statistical test to assess whether these differences are significant

# We will use the tableone package, which helps you to create a "Table 1" for you paper.
#install.packages("tableone")
library(tableone)

CreateTableOne(vars = "baseline_bmi",
               strata = "binge_diag",
               data = analysis_data_binge_bmi)

# We can compare other variables (both categorical and continuous) across strata
CreateTableOne(vars = c("baseline_bmi","baseline_age", "sex", "race"),
               strata = "binge_diag",
               data = analysis_data_binge_bmi)


# What about correlations? Is Age correlated with BMI? Is this relationship different by Binge diagnosis?

# Let's first create a scatter plot for the whole sample
ggplot(analysis_data_binge_bmi, aes(x = baseline_age, y=baseline_bmi)) +
        geom_point()

# Let's add a regression line
ggplot(analysis_data_binge_bmi, aes(x = baseline_age, y=baseline_bmi)) +
        geom_point() + 
        geom_smooth(method=lm, se=FALSE)

# Let's test the correlation:
cor.test(analysis_data_binge_bmi$baseline_age, analysis_data_binge_bmi$baseline_bmi)


# Now, let's do the same by binge eating disorder group
ggplot(analysis_data_binge_bmi, aes(x = baseline_age, y=baseline_bmi)) +
        geom_point() + 
        geom_smooth(method=lm, se=FALSE) +
        facet_wrap(~binge_diag)


# For the correlations, we might have to create 2 data frames one per group:
no_binge_df <- analysis_data_binge_bmi %>%
        filter(binge_diag=="No")

yes_binge_df <- analysis_data_binge_bmi %>%
        filter(binge_diag=="Yes")

# Correlation in No Binge group
cor.test(no_binge_df$baseline_age, no_binge_df$baseline_bmi)

# Correlation in Yes Binge group
cor.test(yes_binge_df$baseline_age, yes_binge_df$baseline_bmi)



# Linear regression example

# We will use the package jtools that helps interpreting coeficients of logistic regression models
#install.packages("jtools")
library(jtools)

# We can use linear regression when we have a continuous outcome and a categorical or continuous predictor/exposure
# Let's determine the effect of age on BMI
model1 <- glm(baseline_bmi ~ baseline_age, data = analysis_data_binge_bmi)
summary(model1)
summ(model1)

# Let's determine if this association changes after we adjust for sex (e.g., add another term in the regression)
model2 <- glm(baseline_bmi ~ baseline_age + sex, data = analysis_data_binge_bmi)
summ(model2)

# What happens if we add binge_diag and race?
model3 <- glm(baseline_bmi ~ baseline_age + sex + binge_diag + race, data = analysis_data_binge_bmi)
summ(model3)
summ(model3, digits = 4)

# Let's now run a model looking at the effect of age on BMI, but separately for each bing eating disorder group, adjusted by covariates
model4_no_binge <- glm(baseline_bmi ~ baseline_age + sex + race, data = filter(analysis_data_binge_bmi, binge_diag=="No"))
summ(model4_no_binge, digits = 4)

model4_yes_binge <- glm(baseline_bmi ~ baseline_age + sex + race, data = filter(analysis_data_binge_bmi, binge_diag=="Yes"))
summ(model4_yes_binge, digits = 4)


# Logistic regression example

# We can use logistic regression when we have a binary outcome and a categorical or continuous predictor/exposure
# Let's determine the effect of BMI on the odds of having a binge eating disoder diagnosis
model_log1 <- glm(binge_diag ~ baseline_bmi, data = analysis_data_binge_bmi, family = binomial(link = "logit"))
summ(model_log1, exp = T, digits = 4)

# Let's now adjust for other covariates such as age, sex and race
model_log2 <- glm(binge_diag ~ baseline_bmi + baseline_age + sex, data = analysis_data_binge_bmi, family = binomial(link = "logit"))
summ(model_log2, exp = T, digits = 4)
