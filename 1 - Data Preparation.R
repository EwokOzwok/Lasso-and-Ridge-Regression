df<-read.csv("Baseline_Calendly_Hubspot Data Combined [no emails].csv", header=T, sep=",", encoding='utf-8-rom')


# Data Load and Missingness part 1 ----------------------------------------


# Examine patterns of missing data
library(finalfit)
finalfit::missing_plot(df)

# View Columns in Dataset
colnames(df)

# Turn NA for Graduate Student (0 vs. 1) into 0's
df$GraduateStudent<-ifelse(is.na(df$GraduateStudent)==T, 0, df$GraduateStudent)

# Create a new dataframe to display missing data for each variable
missing_df<-as.data.frame(matrix(data=NA, ncol = 3, nrow = ncol(df)))

colnames(missing_df)<-c("variable", "missingcount", "missingproportion")

missing_df$variable<-colnames(df)

for(i in 1:ncol(df)){
  missing_df[i,2]<-sum(is.na(df[,i])==T)
  missing_df[i,3]<-sum(is.na(df[,i])==T) / nrow(df)
}

# Compile list of variables that are missing 100% of rows...
missing_all<-missing_df[missing_df$missingproportion==1,]

allmissing_list<-missing_all$variable

# Print the list of variables that are missing at 100% 
allmissing_list


# Make new dataframe that removes all variables that have 100% missingness
df_missing_removed<-dplyr::select(df, -allmissing_list)

colnames(df_missing_removed)

# Removing more columns that cannot be used (i.e., TEXT responses to some 'other' items)
df_missing_removed<- df_missing_removed[,-c(1:8, 10:20, 23:26, 15,16,26,36,52,53,56,58,68:69,71:80,90:95,115,121:287,324:334,349:410,420:424)]
finalfit::missing_plot(df_missing_removed)
colnames(df_missing_removed)



# Find column numbers for variables that need to be converted to "numeric"
# Also turns NAs in these columns into 0's
numcols<-c(1,3:28,32:39, 42:55, 68:70, 73:109)

for(col in numcols){
  df_missing_removed[,col]<-as.numeric(unlist(df_missing_removed[,col]))
  df_missing_removed[,col]<-ifelse(is.na(df_missing_removed[,col])==T, 0, df_missing_removed[,col])
}
finalfit::missing_plot(df_missing_removed)


# Create a new dataframe to display missing data for each variable
missing_df<-as.data.frame(matrix(data=NA, ncol = 3, nrow = ncol(df_missing_removed)))
colnames(missing_df)<-c("variable", "missingcount", "missingproportion")
missing_df$variable<-colnames(df_missing_removed)

for(i in 1:ncol(df_missing_removed)){
  missing_df[i,2]<-sum(is.na(df_missing_removed[,i])==T)
  missing_df[i,3]<-sum(is.na(df_missing_removed[,i])==T) / nrow(df_missing_removed)
}


# Remove last bits of high missingness in dataframe
colnames(df_missing_removed)
df_missing_removed<-dplyr::select(df_missing_removed, -B_Transgender, -S_LangChoice)
finalfit::missing_plot(df_missing_removed)


# Remove NA cases from final dataframe (clean_df)
clean_df<-na.omit(df_missing_removed)
finalfit::missing_plot(clean_df)


colnames(clean_df)


# Recorded Date and Student Stress Level ----------------------------------
# First 2 weeks of semester is very low stress - syllabi weeks, no quizzes and minimal homework
# Stress increases around the first month for most students probably
# Stress peaks for most student probably reading week before finals and before grades come back

clean_df$RecordedDate
# Critical Dates for stress in the semester: 
# Lowest Stress (0) = 1/17/24 - 2/14/24
# Coasting Stress (1) = 2/15/24 - 3/15/24
# Lower Stress (0) = 3/16/24 - 3/22/24 
# Highest Stress (1) = 3/23/24 - 5/8/24


## CHAT GPT PROMPT ##
# I have a column called RecordedDate in an R dataframe called clean_df. Each row of RecordedDate is formatted like this: 2/20/2024 10:51
# Can you write me some R code using the lubridate package that will create a new variable called SemesterStress
# Use the values of RecordedDate to assign SemesterStress a 0 or 1 according to the guidelines below:
# SemesterStress = 0 if RecordedDate is 1/17/24 - 2/14/24 or 3/16/24 - 3/22/24 
# SemesterStress = 1 if RecordedDate is 2/15/24 - 3/15/24 or 3/23/24 - 5/8/24

# Load the necessary library
library(lubridate)

# Convert RecordedDate to datetime format
clean_df$RecordedDate <- mdy_hm(clean_df$RecordedDate)

# Create the SemesterStress variable
clean_df$SemesterStress <- with(clean_df, ifelse(
  (RecordedDate >= mdy("1/17/2024") & RecordedDate <= mdy("2/14/2024")) |
    (RecordedDate >= mdy("3/16/2024") & RecordedDate <= mdy("3/22/2024")),
  0,
  ifelse(
    (RecordedDate >= mdy("2/15/2024") & RecordedDate <= mdy("3/15/2024")) |
      (RecordedDate >= mdy("3/23/2024") & RecordedDate <= mdy("5/8/2024")),
    1,
    NA  # Assign NA if the date does not fall into any of the specified ranges
  )
))


table(clean_df$SemesterStress)
hist(clean_df$SemesterStress)

# Display the dataframe with the new SemesterStress variable
print(clean_df)
head(clean_df)



# Prepare data for investigating depression
clean_df<-clean_df[,-c(2)]

colnames(clean_df)
clean_df<-clean_df[clean_df$Hispanic < 94, ]

clean_df<-clean_df[clean_df$UA_SUICIDE_Attempted < 5, ]
clean_df<-na.omit(clean_df)

finalfit::missing_plot(clean_df)

clean_df$SemesterStress<-as.numeric(unlist(clean_df$SemesterStress))

clean_df<-clean_df[clean_df$UA_SUICIDE_Considered < 5, ]

table(clean_df$UA_SUICIDE_Considered)

colnames(clean_df)


# Splitting the Data into Training and Testing subsamples -----------------


library(caTools)
set.seed(123)  # For reproducibility
split <- sample.split(clean_df$UA_SUICIDE_Attempted, SplitRatio = 0.7)  # 70% training data

# Create training and testing sets
training <- subset(clean_df, split == TRUE)
testing <- subset(clean_df, split == FALSE)



# Separating all predictors (X) from outcome (y) --------------------------

X_train<-training[,-c(120)]
X_test<-testing[,-c(120)]

y_train<-training[,c(120)]
y_test<-testing[,c(120)]

colnames(X_train)



# Load the reticulate package & Activate python environment ---------------

library(reticulate)
use_condaenv("mlbase", required=T)
py_config()


# Convert R objects to PY objects (X_train_py is the python object --------

X_train_py<-r_to_py(X_train)
X_test_py<-r_to_py(X_test)


y_train_py<-r_to_py(y_train)
y_test_py<-r_to_py(y_test)
