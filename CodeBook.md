#CodeBook

###Intro / Summary of Data Description and Analysis

###Data Set and Description 

Original Data Description http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Original Data Source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

###Variables Used and Modified
The data used in this archive were both the test and training sets.
*X,Y,and subject_test
*X,Y,and subject_train

These data were merged using rbind() and colbind.  This formed a 10299 by 69 tidied dataset after steps 1-4 were completed

###activity_labels.txt
Activity ID and Labels  were used and merged into the new master dataset generated
* 1 WALKING
* 2 WALKING_UPSTAIRS
* 3 WALKING_DOWNSTAIRS
* 4 SITTING
* 5 STANDING
* 6 LAYING

###features.txt - Defines the column index and variable name(s) of the test and training data mentioned above
Only variables that were named with mean(-mean() and standard deviation( -std() ) were extracted from the data set.
There should be 69 total variable, 66 are mean or standard deviation data

*The following are example names that were extracted from the original set of 561 variables:
*3 tBodyAcc-mean()-Z
*4 tBodyAcc-std()-X
*...
*268 fBodyAcc-mean()-Z
*269 fBodyAcc-std()-X
*...

Variable names were also modified from the source in the following manner:
*f - Variables starting with "f" were replaced with freq
*t - Variables starting with "t" were replaced with time
*Acc - were substituted with Accelerator
*Mag - were substituted with Magnitude
*Gyro - were substituted with Gyrometer
*"-" - were substituted with "_"

##Tidy Data Set
*The tidy.txt data set was generated from the above dataset and had an aggregate function applied to each activity for each subject(person).
*The results of this aggregate data were sorted by subject and then sorted by activity.  
*This tidy data is written to tidy.txt file
*There are 180 observations of the mean-calculated data per activity, per person.

###Variables Not Used
No Inertial Signal data were used from this archive in this analysis