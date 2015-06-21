## Coursera Data Science course Getting Data (course 3) class project

## This script performs the following tasks 
## 1) merge training and testing data sets from Samsung Galaxy S accelerometers.
## 2) Then extracts the mean and standard deviation columns for all measures
## 3) Uses descriptive activity names for the activities in the data set
## 4) Renames Columns to Descriptive Names
## 5) Create tidy data set


## Install Libraries
library(data.table)
library(dplyr)
library(reshape2)


## Get directories for extracting data files (must be in the directory where the dataset was unzipped)
working_dir <- getwd()
data_dir <- paste(working_dir, "/UCI HAR Dataset", sep = "")
test_dir <- paste(working_dir, "/UCI HAR Dataset/test", sep = "")
train_dir <- paste(working_dir, "/UCI HAR Dataset/train", sep = "")


## Get test subject_test, X_test, and y_test files
setwd(test_dir)
subject_test <- read.table("subject_test.txt", quote="\"")
X_test <- read.table("X_test.txt", quote="\"")
y_test <- read.table("y_test.txt", quote="\"")
setwd(working_dir)


## Get Train subject_train, X_train, and y_train
setwd(train_dir)
subject_train <- read.table("subject_train.txt", quote="\"")
X_train <- read.table("X_train.txt", quote="\"")
y_train <- read.table("y_train.txt", quote="\"")
setwd(working_dir)

## Get activity_labels and features
setwd(data_dir)
activity_labels <- read.table("activity_labels.txt", quote="\"")
features <- read.table("features.txt", quote="\"")
setwd(working_dir)

## Combine train and test sets
all_train <- cbind(subject_train, y_train, X_train)
all_test <- cbind(subject_test, y_test, X_test)

## Combine train and test tables
all_xy = rbind(all_train, all_test)


## Create Column Names from feature list and activity
variable_names <- as.character(features[ , 2])
column_names <- c("Subject", "Activity", variable_names)

## apply column names
colnames(all_xy) <- column_names

## Select only columns with mean and std in name
duplicated_column_names_test <- duplicated(column_names)  ## Find duplicate column names
deduped_all_xy <- subset(all_xy, select = !duplicated_column_names_test) ## Remove columns with duplicates to allow for select
df <- select(deduped_all_xy, 1:2, contains("mean()"), contains("std()"))


## Convert activities to descriptive text
df$Activity[df$Activity == 1] <- "Walking"
df$Activity[df$Activity == 2] <- "Walking Upstairs"
df$Activity[df$Activity == 3] <- "Walking Downstairs"
df$Activity[df$Activity == 4] <- "Sitting"
df$Activity[df$Activity == 5] <- "Standing"
df$Activity[df$Activity == 6] <- "Laying"

## Create tidy data set with the average of each variable for each activity and each subject.
variable_names_subset <- colnames(df[3:68])
df_melt <- melt(df, id = c("Subject", "Activity"), measure.vars=variable_names_subset)
df_tidy <- dcast(df_melt, Subject + Activity ~ variable, mean)

## Export the tidy data file
write.table(df_tidy, file = "tidydata.txt", row.name=FALSE)