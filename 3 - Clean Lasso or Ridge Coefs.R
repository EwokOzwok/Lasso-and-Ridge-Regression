library(caret)
library(caTools)
options(scipen = 999)  # Disable scientific notation


ridge_coef<- read.csv("Ridge_Coefficients.csv", header = T, sep = ',', encoding = 'utf-8-rom')

ridge_coef$Abs_value <- abs(ridge_coef$Coefficient)

ridge_coef<- ridge_coef[ridge_coef$Abs_value > .03, ]

New_df<-dplyr::select(clean_df, UA_SUICIDE_Attempted, ridge_coef$Variable)

set.seed(123)  # For reproducibility
split <- sample.split(New_df$UA_SUICIDE_Attempted, SplitRatio = 0.7)  # 70% training data

New_df<-na.omit(New_df)

for(i in 2:19){
  New_df[,i]<-mean(New_df[,i])-New_df[,i]
}

New_df$UA_SUICIDE_Attempted

# Create training and testing sets
training <- subset(New_df, split == TRUE)
testing <- subset(New_df, split == FALSE)






fit<-lm(UA_SUICIDE_Attempted~., data = training)
summary(fit)

# Generate predictions
pred <- round(predict(fit, testing), 0)

# Calculate error
error <- pred - testing$UA_SUICIDE_Attempted

# Calculate MAE
MAE <- mean(abs(error))
print(paste("Mean Absolute Error (MAE):", round(MAE, 3)))

# Calculate Standard Error
SE <- sd(error)
print(paste("Standard Error (SE):", round(SE, 3)))

# Plot histogram of errors
hist(error, main="Histogram of Prediction Errors", xlab="Error")

# Calculate mean of the actual values
mean_actual <- mean(testing$UA_SUICIDE_Attempted)
print(paste("Mean of Actual Values:", round(mean_actual, 3)))

# Calculate Total Sum of Squares (TSS)
TSS <- sum((testing$UA_SUICIDE_Attempted - mean_actual)^2)

# Calculate Residual Sum of Squares (RSS)
RSS <- sum(error^2)

# Calculate R-squared (R2)
R2 <- 1 - (RSS/TSS)
print(paste("R-squared (R2):", round(R2, 3)))









