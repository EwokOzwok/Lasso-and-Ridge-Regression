df<-read.csv("Baseline_Calendly_Hubspot Data Combined [no emails].csv", header=T, sep=",", encoding='utf-8-rom')

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


# Prepare data for investigating depression
clean_df<-clean_df[,-c(2)]

X<-clean_df[,-c(120)]
y<-clean_df[,c(120)]

colnames(X)


library(reticulate)
use_condaenv("mlbase", required=T)
X_py<-r_to_py(X)
y_py<-r_to_py(y)

colnames(clean_df)



