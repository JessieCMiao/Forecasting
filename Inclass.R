## Store Item Demand


## Libaries I need 
library(forecast)
library(tidyverse)
library(lubridate)

## Read in the data 
store.train <- vroom::vroom("./train.csv")
store.test <- vroom::vroom("./test.csv")

#combine the dataset 
store <-bind_rows(store.train, store.test)
head(store)

#look in to the data 
head(store.train)
store.train %>% filter(store==1, item== 1)

## number of stores/item
with(store, table(item, store)) #50 items and 10 stores

#Plot sales by month 
ggplot(data = store.train %>% filter(item == 1), 
       mapping = aes(x = month(date) %>% as.factor(), y = sales)) + 
  geom_boxplot()
#item 1 sales goes up by the summer 

#take month out and create a column for month and change month as factor 
store <- store %>% mutate(month = as.factor(month(date)))
head(store)


# Sales of item by store 
ggplot(data= store.train %>% filter(item ==17), 
       mapping = aes(x = date, y= sales, color = as.factor(store))) + 
  geom_line()
#sales are increasing, and seasonal effect 


store <- store %>% mutate(year = as.factor(year(date)),
                          time = year(date)+yday(date)/365)

ggplot(data = store  %>% filter(item ==17, store ==7), 
       mapping = aes(x = time, y= sales))+ 
  geom_line() + geom_smooth(method = "lm")


## LM with time and month 
mt.lm <- lm(sales ~ month+time, data = (store %>% filter(item ==17, store==7)))
fit.vals <- fitted(mt.lm)
plot(x = (store %>% filter(item ==17, store==7) %>% pull(time)),
    y = store %>% filter(item ==17, store==7) %>% pull(sales), type = "l")
lines((store %>% filter(item ==17, store==7, !is.na(sales)) %>% pull(time)),
      fit.vals, col = "red", lwd = 2) 


## weekend effect 
ggplot(data= store.train %>% filter(item ==1), 
       mapping = aes(x = wday(date, label = TRUE) %>% as.factor (), y = sales)) + 
  geom_boxplot()




##
ggplot(data= store.train, 
       mapping = aes(x = as.factor(store), y= sales)) + 
  geom_boxplot() + facet_wrap(~as.factor(item))


ggplot(data= store.train %>% filter(item ==17), 
       mapping = aes(x = as.factor(store), y= sales)) + 
  geom_boxplot() 

#We should tried to do: 
#create explanatory varibales from feature engineering 
##SARIMA(p,d,q,P,D,Q) #times series model 
#pdq control day to day (as they goes bigger, the higher correlation comes day to day)
#PDQ control season by season

#auto.arima() similar to caret
y <- store.train %>% filter (item == 17, store ==7) %>% 
  pull(sales) %>% ts(data = ., start = 1, frequency = 365) #define variable to time series object, star 
arima.mod <- auto.arima(y = y, max.p = 2, max.q = 2)
#build a bunch of xs for explanatory varibles
#use xreg= ..... in our auto.arima
#by store # by item 
#for loop 
preds <- forecast(arima.mod, h = 90)
plot(preds)



