library(reshape2)


#sets working directory to inside UCI HAR Dataset
setwd('./UCI HAR Dataset')

#reads the list of features and converts it to character vector
features <- read.table('features.txt')
features$V2 <- as.character(features$V2)

#removes other characters to make variable names readable
features.rem <- grep('.*mean.*|.*std.*',features[,2])
features.names <- features[features.rem,2]
features.names <- gsub('-mean','Mean',features.names)
features.names <- gsub('-std','Std',features.names)
features.names <- gsub('[()]','',features.names)
features.names <- gsub('-','',features.names)

#reads activity labels
activity <- read.table('activity_labels.txt')
activity[,2] <- as.character(activity[,2])

#reading training data
subject <- read.table('train/subject_train.txt')
#separating the 79 mean and standard deviation variables we need
train <- read.table('train/X_train.txt')[features.rem]
activity.label <- read.table('train/y_train.txt')

train.data <- cbind(subject,activity.label,train)


#reading testing data
subject <- read.table('test/subject_test.txt')
#separating the 79 mean and standard deviation variables we need
test <- read.table('test/X_test.txt')[features.rem]
activity.label <- read.table('test/y_test.txt')

test.data <- cbind(subject,activity.label,test)

#combining test and train data
total.data <- rbind(train.data,test.data)
names(total.data)[1] <- 'subject'
names(total.data)[2] <- 'activity.id'

total.data <- merge(activity,total.data,by.x='V1',by.y='activity.id')
names(total.data)[1] <- 'activity.id'
names(total.data)[2] <- 'activity.label'
names(total.data)[3] <- 'subject'
names(total.data)[4:82] <- features.names

#melting data to find mean
total.data.melt <- melt(total.data, id = c("subject", "activity.label","activity.id"))
total.data.mean <- dcast(total.data.melt, subject + activity.id + activity.label~ variable, mean)
total.data.mean$activity.id <- NULL

setwd('..')

#final output file
write.table(total.data.mean,'tidy.txt',row.names = FALSE)
