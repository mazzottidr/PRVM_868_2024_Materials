# PRVM 868 - Biomedical Informatics Driven Clinical Research
# Instructor: Diego R. Mazzotti, Ph.D.
# University of Kansas Medical Center


#########
#
# Part I: Review of some R basics
#
#########


# Basic Syntax - try running some of these commands using the Console below

# Variable (object) assignment
x <- 4
y = 2

# Basic calculations and assignment results to new object
x + y
z <- x + y
z

# A function to print the contents of a variable
print(z)

# Assignment of different data types
x <- "a"
y <- "b"

# Will this work?
z <- x + y

# A function to concatenate strings
z <- paste(x,y, sep = "-")
z

# Comparing contents of an object
x == y
x != y

a <- 1
b <- 10

a > b
a >= b

# QUESTION: How do we test if a is different than b?




# Mathematical functions
a + b
a - b
a * b
a / b
b^2
sqrt(b)
log(b,2) 
log(b) #default at natural log


# QUESTION: how would you calculate BMI, given the weight (wt) and height (ht) below?
wt = 75.3 # in kg
ht = 1.75 # in m




# R Data Types

#Numeric
n <- 15
n
class(n)

# Integer
n <- 15L
n
class(n)

# Character / String
c1 <- "c"
c1
class(c1)

c2 <- "a string of text"
c2
class(c2)

# Logical
l1 <- TRUE
l1
l1 <- T
l1

l2 <- FALSE
l2 <- F

# QUESTION: how do I compare if l1 is equal to l2?
l1==l2


# R Data Structures

# Vectors
# The function c() concatenates elements into a vector
v1 <- c(1, 2, 3, 4, 5)
v1
is.vector(v1)
class(v1)

v2 <- 1:10 # sequence of numbers
v2

v3 <- c("a", "b", "c")
v3
class(v3)

v4 <- letters[1:12] # letters is a default variable containing all letters of the alphabet
v4
class(v4)

v5 <- c(TRUE, TRUE, FALSE, FALSE, TRUE)
v5
class(v5)

v6 <- c("a",1,TRUE)
v6

# QUESTION: what happened to v6?




# Factor variables
v7 <- c("Male", "Female", "Female", "Male", "Female")
v7
v7 <- as.factor(v7)
v7
levels(v7)

# Data Frame - it may be composed of vectors of different types
df <- data.frame(v_Numeric=c(1, 2, 3),
                 v_Character=c("a", "b", "c"),
                 v_Logical=c(T, F, T))
df
class(df)

# View the data frame using RStudio
View(df)



####### Organization tips when working with R scripts

### 1. Make sure you know where in your computer you are working on (e.g., what is your working directory)
# You can find 'where you are' by looking at the path shown in the top part of the console or using the function below
getwd()

### 2. If you are not where you thought you were, you need to change to a new working directory.
# You can do this by navigating to the desired directory folder and clicking "More > Set as working directory" or using the function below, providing the full path to your desired folder:
setwd("/home/droblesmazzotti/")

### 3. It is a good idea to always create a new folder for each new analysis you are doing, and have all your files (scripts, data) available in that folder

### 4. If you need a package that contains functions you may need for your work, make sure you install it first (only needs to be done once), and then load it using the function library. See below:
install.packages("lubridate") # done only once
library(lubridate) # done once every new session starts


#########
#
# Part II: Loading data in R
#
#########

# First, let's create a new folder to store our analyses
# Use the navigator on the right to create a folder named "class"
# then use the upload button to upload the files "sample-data.csv" and "sample-patient.csv". You can find these files in our shared class folder
# Next, make sure your you set this folder as your new working directory!

# You then should be able to load these csv files using the function read.csv. Let's work with the "sample-patient.csv" first:

sample_patient <- read.csv("sample-patient.csv", stringsAsFactors = F)

# If your data is available as a plain text file (e.g., .txt), you should use read.table. There are many arguments in read.table, which lets you decide separators (space, tabs, commas), whether data has header or not, etc.

# There are also packages that lets you read data from Excel, but sometimes is easier to just save your Excel spreadsheet as .csv, to minimize the impact of formatting issues

# After loading was successful, you can use head() to get a snippet of the first 6 rows, or View() to show the data frame in RStudio
head(sample_patient)

View(sample_patient)



#########
#
# Part III: Basic data frame operations
#
#########

# Sub-setting dataframes

# Getting columns using $
sample_patient$patient_num

# Sub-setting using square brackets

# Columns
sample_patient[,2]
sample_patient[,1:3]
sample_patient[,c(1,3,5)]

# Rows
sample_patient[1,]
sample_patient[1:10,]

# Both
sample_patient[1:10,1:3]


# Creating new columns

# A constant column:
sample_patient$constant <- "All patients"
head(sample_patient)

# A column with results of an operation
sample_patient$age_months <- sample_patient$age*12
head(sample_patient)

# A column with results of a logical operation
sample_patient$age_50 <- sample_patient$age>=50
head(sample_patient)


# Simple summary statistics from a data frame
# number of rows
nrow(sample_patient)

# number of columns
ncol(sample_patient)

# dimensions (a vector with 2 elements, rows and columns, in order)
dim(sample_patient)

# Counts of categorical variables
table(sample_patient$vital_status)
table(sample_patient$sex)

# Summary statistics
mean(sample_patient$age)
sd(sample_patient$age)
min(sample_patient$age)
max(sample_patient$age)

# Replacing values to clean the dataset
# Replacing with NA
table(sample_patient$vital_status)
sample_patient$vital_status=="@"
sample_patient$vital_status[sample_patient$vital_status=="@"]
sample_patient$vital_status[sample_patient$vital_status=="@"] <- NA
sample_patient$vital_status
table(sample_patient$vital_status)
table(sample_patient$vital_status, useNA = "always")

# Changing class character to factor
class(sample_patient$vital_status)
sample_patient$vital_status <- as.factor(sample_patient$vital_status)
levels(sample_patient$vital_status)
levels(sample_patient$vital_status) <- c("Alive", "Dead")
levels(sample_patient$vital_status)


# QUESTION: How many patients are 18 years old or older?
# QUESTION: rename the levels of sex to Female and Male
# QUESTION: Create a variable named religion_yn that is NA for @ or unknown, "No" for none and "Yes" for all others. This variable should be a factor

