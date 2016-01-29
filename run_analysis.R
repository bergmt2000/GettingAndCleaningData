#Course Project For Getting and Cleaning Data - Coursera 

##Script does the following tasks

## 1 - Merges the training and the test sets to create one data set.
## 2 - Extracts only the measurements on the mean and standard deviation for each me?setasurement.
## 3 - Uses descriptive activity names to name the activities in the data set
## 4 - Appropriately labels the data set with descriptive variable names.
## 5 - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(plyr)
library(dplyr)
library(data.table)
#library(reshape2)


## Example code to get a merged data set in console, independent of the tidy data set/file generated in step 5
###myData <- buildDataset()
###return(myData)


##DownloadData simply fetches the archive to the current working directory if it doesn't exist locally, 
##unzips the archive, assumes current working dir
downloadData <- function()
{
    fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    zipFileName <- "UCIHARDataset.zip"
    extractDir <- "UCIHARDataset"
    if (!file.exists(zipFileName))
    {
        #download the file
        print(paste("Downloading File: ", zipFileName, " from ", fileUrl))
        download.file(fileUrl, zipFileName)
        print(paste( "Unzipping File from Archive: ", zipFileName))
        n <- unzip(zipfile = zipFileName, exdir = extractDir)
        print (paste("n is:", n))
    }

    ##Returns the archive's root directory path/foldername
    return (paste0(extractDir, .Platform$file.sep, "UCI HAR Dataset"))
}


##buildDataSet() is the master function of all control flow
##All steps are contained within this function

buildDataset <- function()
{
    #Fetch the archive data
    rootFolder <- downloadData()

    ## Step 1
    ## Merge all the training and the test sets to create one data set named allData.
    allData <- getData(rootFolder)
    
    ## Step 2
    ## Extract mean and StdDev data, subset with the grepped fields
    allData <- allData[,grep("ActivityID|SubjectID|-mean\\(\\)|-std\\(\\)", names(allData))]
    
    
    ##Step 3 - Uses descriptive activity names to name the activities in the data set
    ##Now let's get the descriptive activity labels..which is really just a lookup table to be merged
    dtActivityLabels <- getActivityLabels(rootFolder)
    
	#Join datasets and reorganize them with the keys in the beginning or the data frame
    allData <- join(x = allData, y = dtActivityLabels, by = "ActivityID")
    allData <- select(allData, SubjectID, ActivityID, ActivityName, everything())

    
    ##Step 4, Appropriately labels the data set with descriptive variable names.
    ##Pretty up the column names a bit for the data table
    allData <- tidyUpVariableNames(allData)
    
    
    ## Step 5
    ##From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
    tidyData <- select(allData, everything(), -ActivityName)   #Lose the activity descriptive name for aggregate calc below
    tidy <- aggregate(tidyData, by = list(tidyData$ActivityID, tidyData$SubjectID), FUN=mean, na.rm=TRUE  )
    
    #subset fields 1 and to 2 to get rid of group.1 and group.2
    tidy <- tidy[,3:length(colnames(tidy))]
    tidy <- tidy %>% 
        join(dtActivityLabels) %>%      #merge activity name back in
        select(SubjectID, ActivityID, ActivityName, everything()) %>%
        arrange(SubjectID, ActivityID)  #sort by SubjectID and ActivityID

    #Write the tidy file
    print("Saving File to local working directory: tidy.txt")
    write.table(tidy, file = "tidy.txt",row.names = FALSE, sep = ",", col.names = TRUE)
    
    #return the original cleaned dataset back to the caller, if they want to use
    return(allData)
}


##Function returns the lookup table of Activity Labels File
getActivityLabels <- function(rootFolder)
{
    fileName   <- "activity_labels.txt"
    dtActivity <- read.table(file.path(getwd(), rootFolder, fileName , fsep = .Platform$file.sep))
    setnames(dtActivity, c("V1", "V2"), c("ActivityID", "ActivityName"))
    return(dtActivity)
}


##Iterates over the column names and pulls out some symbols and extend the names for reference
##Returns the passed in DF/DT with the new column names
tidyUpVariableNames <- function(df)
{

    df_colnames <- colnames(df)
    for(i in 1:length(df_colnames) )
    {
        #check the column name and gsub out characters that are untidy
        df_colnames[i] <- gsub(pattern = "\\)", replacement = "",  x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "\\(", replacement = "",  x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "-mean", replacement = "_Mean", x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "-std", replacement = "_StdDev", x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "-", replacement = "_", x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "^f", replacement = "freq", x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "^t", replacement = "time", x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "Mag", replacement = "Magnitude",x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "Acc", replacement = "Accelerator",x = df_colnames[i])
        df_colnames[i] <- gsub(pattern = "Gyro", replacement = "Gyroscope",x = df_colnames[i])
    }
    
    #Merge the new names to the df and return the altered data frame
    colnames(df) <- df_colnames
    return(df)
}


##Function returns a data table/frame of the measured variables named "features"
getFeatureNames <- function(rootFolder)
{
    fileName   <- "features.txt"
    dtFeatures <- read.table(file.path(getwd(), rootFolder, fileName , fsep = .Platform$file.sep))
    return(dtFeatures)
}


##Function merges the test and training data into one data table/frame
## -- Just to note, this whole program uses data frames.  
## -- I Started using data tables and fread's for loads, which was way way faster, but df subsetting and manipulation was easier
## -- than data table maniuplation.  And I had time constraints to get this done
getData <- function (rootFolder)
{
    #Features Data
    featTrainPath <- file.path(getwd(), rootFolder,  "train", fsep = .Platform$file.sep, "X_train.txt" )
    featTestPath  <-file.path(getwd(),  rootFolder,  "test" , fsep = .Platform$file.sep, "X_test.txt")
    
    dtFeatureTrain <- read.table(featTrainPath, header=FALSE) 
    dtFeatureTest  <- read.table(featTestPath, header=FALSE)
    dtFeature <- rbind(dtFeatureTrain, dtFeatureTest)
    
    dtFeatureNames <- getFeatureNames(rootFolder)
    names(dtFeature) <- dtFeatureNames[,2]
    
    
    #Activity Labels
    activityTrainPath <- file.path(getwd(), rootFolder,  "train", fsep = .Platform$file.sep, "y_train.txt" )
    activityTestPath  <- file.path(getwd(), rootFolder,  "test" , fsep = .Platform$file.sep, "y_test.txt")
    
    dtActivityTrain <- read.table(activityTrainPath, header=FALSE)
    dtActivityTest  <- read.table(activityTestPath,  header=FALSE)
    dtActivity <- rbind(dtActivityTrain, dtActivityTest)
    setnames(dtActivity, "V1", "ActivityID") 

    #Subject Data
    subjectFileTrain <- file.path(getwd(), rootFolder,  "train", fsep = .Platform$file.sep, "subject_train.txt" )
    subjectFileTest  <- file.path(getwd(), rootFolder,  "test" , fsep = .Platform$file.sep, "subject_test.txt" )
    
    dtSubjectTrain <- read.table(subjectFileTrain, header = FALSE)
    dtSubjectTest  <- read.table(subjectFileTest, header = FALSE)
    dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
    setnames(dtSubject, "V1", "SubjectID")
    

    #Merge all the data tables
    allData <- cbind(dtActivity, dtSubject, dtFeature)
    return(allData)
}
