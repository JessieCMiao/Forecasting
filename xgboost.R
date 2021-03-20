install.packages("lubridate")
install.packages("forecast")
## Libaries I need 
library(forecast)
library(caret)
library(tidyverse)
library(lubridate)
library(DataExplorer)
library(utils)



## Read in the data 
store.train <- vroom::vroom("./train.csv")
store.test <- vroom::vroom("./test.csv")

#combine the dataset 
store <-bind_rows(store.train, store.test)
glimpse(store)

#Feature Engineering 
store$item <- as.factor(store$item) 
store$store <- as.factor(store$store)
store$month <- month(store$date)
store$weekday <- weekdays(store$date)
store$year <- year(store$date)
store$quarter <- quarter(store$date)



store.train <- store[!is.na(store$sales),]
store.test <- store[is.na(store$sales),]

#10 folds repeat 3 times
control <- trainControl(method='repeatedcv', 
                        number=3, 
                        repeats=2)
grid_default <- expand.grid(
  nrounds = 250,
  max_depth = 10,
  eta = 0.3,
  gamma = 15,
  colsample_bytree = .5,
  min_child_weight = 25,
  subsample = 1)

#Metric compare model is Accuracy
metric <- "Accuracy"
set.seed(123)
xgb_default <- train(sales ~ ., 
                     data=store.train %>% select(-id), 
                     method='xgbTree', 
                     trControl=control,
                     tuneGrid = grid_default)

names(xgb_default)
#plot(xgb_default)
xgb_default$bestTune

predictions <- data.frame(id=store.test$id, sales = (predict(xgb_default, newdata=store.test)))
predictions

## write to a csv
write_csv(x = predictions, file = "./submission.csv")





