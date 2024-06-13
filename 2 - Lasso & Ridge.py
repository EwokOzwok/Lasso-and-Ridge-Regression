

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
X = r.X_py
y = r.y_py

# The KFold object in SciKit Learn tells the cross validation object (see below) how to split up the data:

# Initiate KFold Object
kf = KFold(shuffle=True, random_state=72018, n_splits=4)

kf.split(X) # is a generator object

X.describe()

from sklearn.metrics import r2_score, mean_squared_error
from sklearn.model_selection import GridSearchCV

# Same estimator as before
estimator = Pipeline([("scaler", StandardScaler()),
        ("ridge_regression", Ridge())])

params = {
    'ridge_regression__alpha': np.geomspace(4, 20, 30)
}

grid = GridSearchCV(estimator, params, cv=kf)


grid.fit(X, y)


grid.best_score_, grid.best_params_


y_predict = grid.predict(X)


# This includes both in-sample and out-of-sample
r2_score(y, y_predict)


# Notice that "grid" is a fit object!
# We can use grid.predict(X_test) to get brand new predictions!
Ridge_Coefs = grid.best_estimator_.named_steps['ridge_regression'].coef_
Varnames = X.columns

# Zip the two lists together
zipped_list = list(zip(Varnames, Ridge_Coefs))

# Convert the zipped list to a DataFrame
df = pd.DataFrame(zipped_list, columns=['Variable', 'Coefficient'])

# Print the DataFrame
print(df)

df.to_csv('Ridge_Coefficients.csv')

GridResults = pd.DataFrame(grid.cv_results_)
GridResults.rank_test_score.sort_values() 


print(GridResults.loc[29])
print(GridResults.params.loc[29])


grid.best_estimator_
