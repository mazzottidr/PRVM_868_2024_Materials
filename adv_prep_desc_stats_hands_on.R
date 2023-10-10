# PRVM 868 - Biomedical Informatics Driven Clinical Research
# Instructor: Diego R. Mazzotti, Ph.D.
# University of Kansas Medical Center

# If you are starting a new R session, make sure you are in the correct working directory
setwd("~/class/")

# And make sure you load the data
sample_patient <- read.csv("sample-patient.csv", stringsAsFactors = F)


#########
#
# Advanced data frame operations (dplyr)
#
#########

# install.packages("dplyr")
library(dplyr)

# Using the pipe (%>%) operator
sample_patient %>%
        head()

sample_patient %>%
        ncol()

# select columns
sample_patient %>%
        select(patient_num, vital_status, age, sex)

# filter rows
sample_patient %>%
        filter(language=="spanish") %>%
        head()

sample_patient %>%
        filter(language=="english" & race!="white" & age>50)


# mutate new/existing columns
sample_patient %>%
        filter(age<18)

# QUESTION: how many pediatric patients (AGE <18) are in the dataset?


# mutate new/existing several columns
sample_patient %>%
        mutate(IsAdult = age>=18,
               IsMarried = marital_status=="m",
               IsAdult_and_Married = IsAdult & IsMarried) %>%
        View()

# group_by variable and summarize - this allows you to make operations per group of a categorical variable

# Find average of a corresponding column (before summarize)
sample_patient %>%
        summarise(mean(age))

# Find average age by sex:
sample_patient %>%
        group_by(sex) %>%
        summarise(mean(age))

# Add other relevant summary statistics
sample_patient %>%
        group_by(sex) %>%
        summarize(n=n(),   # This counts how many rows per group
                  mean_age=mean(age),
                  sd_age=sd(age),
                  min_age=min(age),
                  max_age=max(age))


# Grouping by more than one variable
sample_patient %>%
        group_by(sex, vital_status) %>%
        summarize(n=n(),   # This counts how many rows per group
                  mean_age=mean(age),
                  sd_age=sd(age),
                  min_age=min(age),
                  max_age=max(age))

# Creating new data frames with subsets of data 
# Let's create a separate data frame with only older adults (age >=65)
older_adults <- sample_patient %>%
        filter(age>=65)

### QUESTION: how many older adults are in the dataset?

### QUESTION: What is the mean age of older adult patients that speak English and are not white? Show the results by sex.



##########################################
##
## Working with an example HERON export
##
##########################################


# The "sample-patient.csv" file is from a HERON request and contains patient-level information.
# We will explore another dataset that is also part of the same HERON request, and contains other relevant variables such as BMI and diagnosis codes.

# Using what you learned today load the file "sample-data.csv" and try to anser the questions below:

sample_data <- read.csv("sample-data.csv", stringsAsFactors = F) # Please note stringsAsFactors argument - it might be easier to set it as false and convert to factor if/when necessary


# How many columns and rows this data set has?
ncol(sample_data)
nrow(sample_data)

# Look at the first 6 rows of the date
head(sample_data)

# How many observations (rows) per patient are available? Try group_by, summarize and n()
sample_data %>%
        group_by(patient_num) %>%
        summarise(n=n())

# How many unique patients are in the data set? Try counting the number of rows from the last table
sample_data %>%
        group_by(patient_num) %>%
        summarise(n=n()) %>%
        nrow()

# How many different variables are available? Try using the function table() in the columns variable
table(sample_data$variable)

# let's look only at the diagnosis of Binge eating disorder. Create a separate data frame that contains only records (rows) that match variable=="Binge eating disorder"
binge_only <- sample_data %>%
        filter(variable=="Binge eating disorder")

# Let's summarise this table so that it contains one record per patient, with the following columns: patient_num, binge_count(count of rows with binge eating diagnoses), earliest_start_date and latest_start date
binge_per_pat <- binge_only %>%
        group_by(patient_num) %>%
        summarise(binge_count=n(),
                  binge_earliest_start_date=min(start_date),
                  binge_latest_start_date=max(start_date))

# Let's do the same thing for Body Mass Index (with counts of bmi, median BMI, and BMI at earliest and latest date)
bmi_per_pat <- sample_data %>%
        filter(variable=="Body Mass Index") %>%
        group_by(patient_num) %>%
        summarise(bmi_count=n(),
                  median_bmi=median(nval),
                  earliest_bmi_start_date=min(start_date),
                  earliest_bmi=nval[start_date==earliest_bmi_start_date],
                  latest_bmi_start_date=max(start_date),
                  latest_bmi=nval[start_date==latest_bmi_start_date])


# Now, lets join the patient table with these 2 datasets using left_join commands in a chain
full_data <- sample_patient %>%
        left_join(binge_per_pat, by = c("patient_num"="patient_num")) %>%
        left_join(bmi_per_pat, by = c("patient_num"="patient_num"))


# We can now calculate the age, in years, of the first diagnosis of binge eating disorder, based on birth date and earliest start date

# we will use a function of the package lubridate, so let's load it
library(lubridate)

full_data <- full_data %>%
        mutate(age_at_first_binge = floor(interval(birth_date, binge_earliest_start_date) / years(1)))


# Let's now see the data completely
View(full_data)


# Finally, let's save these results in a csv file
write.csv(full_data, "full_data_binge_bmi.csv", row.names = F)

