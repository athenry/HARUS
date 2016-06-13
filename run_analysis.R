## This file contains the scripts necessary to produce a tidy dataset by:
## 1. Merging the training and the test sets to create one data set,
## 2. Extracting only the measurements on the mean and standard deviation for each measurement,
## 3. Using descriptive activity names to name the activities in the data set,
## 4. Appropriately labelling the data set with descriptive variable names, and, finally, 
## 5. From the data set in step 4, creating a second, independent tidy data set with the 
##    average of each variable for each activity and each subject.

## Run this script in a directory containing the "UCI HAR Dataset" folder.

## Initialize the required R packages.
library(dplyr)
library(reshape2)

## Read in the test and training data needed.
features <- read.csv("UCI HAR Dataset/features.txt", sep = "", header = FALSE)
activitylabels <- read.csv("UCI HAR Dataset/activity_labels.txt", sep = "", header = FALSE)
columns<- c("subject", "actnum", as.vector(features$V2))

testdata <- read.csv("UCI HAR Dataset/test/X_test.txt", sep = "", header = FALSE)
testsubjects <- read.csv("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
testlabels <- read.csv("UCI HAR Dataset/test/y_test.txt", header = FALSE)
testdata <- cbind(testsubjects, testlabels, testdata)

traindata <- read.csv("UCI HAR Dataset/train/X_train.txt", sep = "", header = FALSE)
trainsubjects <- read.csv("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
trainlabels <- read.csv("UCI HAR Dataset/train/y_train.txt", header = FALSE)
traindata <- cbind(trainsubjects, trainlabels, traindata)

## Combine datasets.
HARdata <- rbind(testdata, traindata)
colnames(HARdata) <- columns

## Remove duplicate columns
HARdata <- HARdata[,unique(names(HARdata), with=FALSE)]

## Select only mean and standard deviation data
selectdata <- select(HARdata, subject, actnum, contains("mean("), contains("std("))

## Use appropriate activity labels.
names(activitylabels) <- c("actnum", "activity")
nameddata <- merge(selectdata, activitylabels, by = "actnum")
nameddata <- select(nameddata, -actnum)

## Average
melted <- melt(nameddata, c("subject", "activity"))
averages <- dcast(melted, subject + activity ~ variable, mean)

## Write tidy result to txt file
write.table(averages, file = "tidy_avgs.txt", row.names = FALSE)