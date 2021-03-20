install.packages("lubridate")
install.packages("forecast")
## Libaries I need 
library(forecast)
library(caret)
library(tidyverse)
library(lubridate)
library(DataExplorer)



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

store <- store %>% 
  group_by(store, item, month) %>%
  mutate(mean_month_sales = mean(sales, na.rm = TRUE)) %>%
  ungroup() %>%
  group_by(store, item, weekday) %>%
  mutate(mean_weekday_sales = mean(sales,na.rm = TRUE)) %>%
  ungroup() %>%
  group_by(store,item, year) %>%
  mutate(mean_year_sales = mean(sales, na.rm = TRUE)) %>%
  ungroup() %>% 
  group_by(store,item, quarter) %>%
  mutate(mean_quarter_sales = mean(sales, na.rm = TRUE)) %>%
  ungroup()


head(store)
summary(store)

store.train <- store[!is.na(store$sales),]
store.test <- store[is.na(store$sales),]

# EDA 
# Distribution of Sales 
ggplot(data = store.train, 
       mapping = aes(x = sales)) + 
  geom_histogram(bins = 20)

# Distribution of Sales by store
ggplot(data = store.train,
       mapping = aes(x = sales)) + 
  geom_histogram(bins = 20) + 
  facet_wrap(~store) 

# Since the above is right skewed, we can do transformation 


#boxcox transformation
bc <- BoxCoxTrans(store.train$sales+1)
bc  # "best" lambda value 0.3

#Predict sales after boxcox transformation
trans_sales<-predict(bc, as.vector(store.train$sales+1))
summary(trans_sales)

store.train$sales<-trans_sales

ggplot(store.train, aes(sales))+
  geom_histogram()+
  ggtitle("Distribution of Sales After Boxcox")

ggplot(store.train, aes(sales, fill = as.factor(store)))+
  geom_histogram()+
  facet_wrap(~as.factor(store))+
  ggtitle("Distribution of Sales by Store After Boxcox")
#The overall distribution of sales is almost perfectly symmetrical
#The distributions of sales by store also look very symmetrical



#Impact of Time with Sales (YEAR)
ggplot(store.train, aes(as.factor(year), sales))+
  geom_boxplot()
#No much difference between year in terms of sales 


#Impact of Time with Sales (Quarter)
ggplot(store.train, aes(as.factor(quarter), sales))+
  geom_boxplot()

ggplot(store.train, aes(as.factor(quarter), sales, fill = as.factor(year)))+
  geom_boxplot()
#From the first plot we can see Quarter 2 and 3 has slightly higher sales and quarter 4 has lower sales
#second plot I group the quarter by years. There is some type of 
#positive relationship between year and sales


#Impact of Time with Sales (Month)
ggplot(store.train, aes(as.factor(month), sales))+
  geom_boxplot()
#distribution shift up and down but December seems to have much drop in sales. 


#Change to log because the metric for the competition is rmsle and also the distribution of counts is skewed.
store$sales = log1p(store$sales)

#Split test/train
store.train <- store %>% filter(!is.na(sales))
store.test <- store %>% filter(is.na(sales))

plot_missing(store.train)
plot_missing(store.test)
#use gbm
gbm <- train(form=sales~.,
             data=store.train,
             method="gbm",
             trControl=trainControl(method="repeatedcv",
                                    number=3, #Number of pieces of your data
                                    repeats=1)) #repeats=1 = "cv"



gbm$results

gbm.preds <- data.frame(Id=store.test$id, sales=predict(gbm, newdata=store.test))



