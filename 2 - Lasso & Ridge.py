
# Grid Search CV

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler, PolynomialFeatures, MinMaxScaler
from sklearn.model_selection import KFold, cross_val_predict
from sklearn.linear_model import LinearRegression, Lasso, Ridge
from sklearn.metrics import r2_score
from sklearn.pipeline import Pipeline


# Read Data
X_train = r.X_train_py
X_test = r.X_test_py

y_train = r.y_train_py
y_test = r.y_test_py

# The KFold object in SciKit Learn tells the cross validation object (see below) how to split up the data:
# Initiate KFold Object
kf = KFold(shuffle=True, random_state=777777, n_splits=4)

kf.split(X_train) # is a generator object

X_train.describe()

from sklearn.metrics import r2_score, mean_squared_error
from sklearn.model_selection import GridSearchCV

# Same estimator as before: 
estimator = Pipeline([("scaler", StandardScaler()),
        ("ridge_regression", Ridge())])

params = {
    'ridge_regression__alpha': np.geomspace(4, 20, 30),
    
}

grid = GridSearchCV(estimator, params, cv=kf)


grid.fit(X_train, y_train)


grid.best_score_, grid.best_params_


y_predict_test = grid.predict(X_test)
y_predict_train = grid.predict(X_train)

r2_score(y_train, y_predict_train)

# This includes both in-sample and out-of-sample
r2_score(y_test, y_predict_test)


# Notice that "grid" is a fit object!
# We can use grid.predict(X_test) to get brand new predictions!
Ridge_Coefs = grid.best_estimator_.named_steps['ridge_regression'].coef_
Varnames = X_train.columns

# Zip the two lists together
zipped_list = list(zip(Varnames, Ridge_Coefs))

# Convert the zipped list to a DataFrame
df = pd.DataFrame(zipped_list, columns=['Variable', 'Coefficient'])

# Print the DataFrame
df.sort_values(by = 'Coefficient', ascending = False)
print(df)

df.to_csv('Ridge_Coefficients.csv')

GridResults = pd.DataFrame(grid.cv_results_)
GridResults.rank_test_score.sort_values() 


print(GridResults.loc[29])
print(GridResults.params.loc[29])


grid.best_estimator_

