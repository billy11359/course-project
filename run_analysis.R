library(dplyr)
fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipfn <- "getdata-projectfiles-UCI HAR Dataset.zip"
destdir <- "UCI HAR Dataset"
if (!file.exists(destdir)) {
  if(!file.exists(zipfn)) {
    ## Download the data file
    download.file(fileURL, destfile=zipfn)
  }
  ## Unzip the data file
  unzip(zipfn)
}
## Read txt file
### Read the activity labels
raw.labels <- read.table(paste(destdir, "/activity_labels.txt", sep=""))
### Read the feature list
raw.features <- read.table(paste(destdir, "/features.txt", sep=""))

### Read the testing datasets
raw.test.subject <- read.table(paste(destdir, "/test/subject_test.txt", sep=""), col.names=c("Subject"))
raw.test.x <- read.table(paste(destdir, "/test/X_test.txt", sep=""))
raw.test.y <- read.table(paste(destdir, "/test/y_test.txt", sep=""), col.names=c("Activity"))
dim(raw.test.subject); dim(raw.test.x); dim(raw.test.y)
raw.train.subject <- read.table(paste(destdir, "/train/subject_train.txt", sep=""), col.names=c("Subject"))
raw.train.x <- read.table(paste(destdir, "/train/X_train.txt", sep=""))
raw.train.y <- read.table(paste(destdir, "/train/y_train.txt", sep=""), col.names=c("Activity"))
dim(raw.train.subject); dim(raw.train.x); dim(raw.train.y)

raw.train.subject <- read.table(paste(destdir, "/train/subject_train.txt", sep=""), col.names=c("Subject"))
raw.train.x <- read.table(paste(destdir, "/train/X_train.txt", sep=""))
raw.train.y <- read.table(paste(destdir, "/train/y_train.txt", sep=""), col.names=c("Activity"))
dim(raw.train.subject); dim(raw.train.x); dim(raw.train.y)

## 1. Data Merge
### Combine subject, y & x for the test set
raw.test <- cbind(raw.test.subject, raw.test.y, raw.test.x)
### Combine subject, y & x for the train set
raw.train <- cbind(raw.train.subject, raw.train.y, raw.train.x)
### Merges the training and the test sets to create one data set
raw.data <- rbind(raw.test, raw.train)
dim(raw.data)

### Put the raw data into dplyr data table
activity <- tbl_df(raw.data)
### mean() and std() column list, need to add up 2 (Subject, Activity)
collist <- grep("[Mm]ean\\()|[Ss]td\\()", raw.features$V2)
colnames <- grep("[Mm]ean\\()|[Ss]td\\()", raw.features$V2, value=TRUE)
collist <- collist + 2
collist <- c(1, 2, collist)
colnames <- c("Subject", "Activity", colnames)
### Select columns
activity <- activity[, c(collist)]

activity$Activity <- as.character(activity$Activity)
raw.labels$V1 <- as.character(raw.labels$V1)
raw.labels$V2 <- as.character(raw.labels$V2)
for( i in 1:nrow(raw.labels) ) {
  activity$Activity <- gsub(raw.labels[i,1], raw.labels[i,2], activity$Activity)
}

names(activity) <- colnames

tidy.data <- group_by(activity, Subject, Activity) %>%
  summarise_each(funs(mean))
names(tidy.data) <- colnames

### Save the tidy dataset
write.table(tidy.data, "./tidydata.txt", row.name=FALSE)

### Load and test 
tidytest <- read.table("./tidydata.txt", header=TRUE)
dim(tidytest); names(tidytest)