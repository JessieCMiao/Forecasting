# Forecasting

a. What is the overall purpose of this project?

The purpose of this notbook is to analysis 5 years of store-item sales and predict 3 future months of sales for 50 different items at 10 different stores.

b. What do each file in your repository do?

test.csv and train.csv are the dataset from the Kaggle competition (https://www.kaggle.com/c/demand-forecasting-kernels-only/data). 
Inclass.R include what Professor Heaton did in class to help us start off this competition. 
Submission.R is my first submission for this Kaggle competition which received a score of 31.65311.
xgbtree.R is my best submission for this Kaggle competition which received a score of 15.54460. 
submission.csv is the prediction result from xgbtree.R file

c. What methods did you use to clean the data or do feature engineering?

With only 4 variables given, I deceide to create various variables using functions from lubridate to extract year, month, weekday, and quarter. Then, I change item and store variables as factor.

d. What methods did you use to generate predictions?

For the Submission.R, I used gradient boosting for the prediction. I choose the response variable as the number of sales, method is gbm and Trcontrol is the controls for the function and predict our test data from our training data results.
For the xgbtree.R, I use XGBTree prediction method. With the same response variable but the tuning parameters were chosen by trying different numbers to try to obtain the lowest RMSE(The values used in grid_default gave the lowest RMSE score). And using XGBTree model to get the prediction. 
