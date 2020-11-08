
library(RPostgres)
library(DBI)
library(yaml) #for sourcing password from local file
library(dplyr)
library(xts)
library(forecast) #for installation on fresh ubuntu prob. neet libcurl4-openssl-dev installed
library(dygraphs)
library(timetk)
library(tibble)
library(purrr)
library(rlang)
library(tibbletime)
library(lubridate)
library(caTools)

#
# LOAD FROM TIMESCALE DB
#

#get password information from yml file
config = yaml.load_file("SECURITY/config.yml")

#Configarations
con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'nyc_data', 
                 host = 'localhost',
                 port = 5432,
                 user = 'postgres',
                 password = config$TIMESCALEDB$PW)

#
# TRY MANUAL SELECT NOT PER VIEW CREATINO IN SCRIPT
#

# dbGetQuery(con, statement = "
# SELECT time_bucket_gapfill('1 hour', pickup_datetime, '2016-01-01 00:00:00','2016-03-31 23:59:59') AS one_hour,
# CAST (AVG(total_amount) AS DOUBLE PRECISION) as price
# FROM rides
# WHERE ST_Distance(pickup_geom, ST_Transform(ST_SetSRID(ST_MakePoint(-74.0113,40.7075),4326),2163)) < 400 
# AND pickup_datetime < '2016-04-01'
# GROUP BY one_hour
# ORDER BY one_hour
#            ;")

count_rides <- dbGetQuery(con, statement = "
SELECT time_bucket_gapfill('1 hour', pickup_datetime, '2016-01-01 00:00:00','2016-01-31 23:59:59') AS one_hour,
COUNT(*) AS count_rides
FROM rides
WHERE ST_Distance(pickup_geom, ST_Transform(ST_SetSRID(ST_MakePoint(-74.0113,40.7075),4326),2163)) < 400 
  AND pickup_datetime < '2016-02-01'
GROUP BY one_hour
ORDER BY one_hour
           ;")

count_rides <- count_rides %>% 
  mutate(count_rides = as.numeric(count_rides))

#
# SET TRAINING TESTING DATA
#

# if used with R controlled split
h <- 24*10
count_rides_train <- head(count_rides, round(length(count_rides) - h))
count_rides_test <- tail(count_rides, h)

#
# LOAD DATA AFTER SCRIPT CREATED VIEWS
#

# count_rides <- dbGetQuery(con, statement = "
# SELECT *
# FROM rides_count
#            ;")
# 
# length_rides <- dbGetQuery(con, statement = "
# SELECT *
# FROM rides_length
#            ;")
# 
# price_rides <- dbGetQuery(con, statement = "
# SELECT *
# FROM rides_price
#            ;")
# 
# str(price_rides)
# str(length_rides)
# str(count_rides)


#
# TRAIN TEST EXAMPLE WITH SQL
#

# if used with sql created tables
# count_rides_train <- dbGetQuery(con, statement = "
# SELECT *
# FROM rides_count_train
#            ;")

# if used with sql controlled split
# count_rides_train <- dbGetQuery(con, statement = "
# SELECT * FROM rides_count
# WHERE one_hour <= '2016-01-21 23:59:59'
# ORDER BY one_hour
#            ;")

###

# if used with sql created tables
# count_rides_test <- dbGetQuery(con, statement = "
# SELECT *
# FROM rides_count_test
#            ;")

# if used with sql controlled split
# count_rides_test <- dbGetQuery(con, statement = "
# SELECT * FROM rides_count
# WHERE one_hour >= '2016-01-22 00:00:00'
# ORDER BY one_hour
#            ;")

#
# ACF TEST
#

Acf(count_rides_train$count_rides)

#
# TRANSFORM DATA TO TIME SERIES IN R (ZOO)
#

zoo_count_rides.test <- count_rides_test %>% 
  mutate(time = as.POSIXct(x = count_rides_test$one_hour, tz = "", format = "%Y-%m-%d %H:%M:%S")) %>% 
  select(c("time", "count_rides")) %>% 
  data.frame() %>% 
  read.zoo()

zoo_count_rides.train <- count_rides_train %>% 
  mutate(time = as.POSIXct(x = count_rides_train$one_hour, tz = "", format = "%Y-%m-%d %H:%M:%S")) %>% 
  select(c("time", "count_rides")) %>% 
  data.frame() %>% 
  read.zoo()

#
# CREATE A QUICK MODEL
#

fit <- nnetar(zoo_count_rides.train)
fc.fit <- forecast(fit, h = h, PI = T, npaths = 10)

#
# ADJUST DATA FOR VISUALISATION
#

#TODO wrap into function.

# create future dates for the time horizon predicted
idx <- zoo_count_rides.train %>%
  tk_index() %>%
  tk_make_future_timeseries(length_out = h)

# Retransform values
zoo_count_rides.fc <- tibble(
  index   = idx,
  value   = fc.fit$mean)

#easy function to avoid double code
ts_to_df <- function(start_ts) {
  end_df <- start_ts %>% 
    tk_tbl() %>% 
    mutate(index = index) %>%
    as_tbl_time(index = index) %>% 
    data.frame()
}
#add "actual" string for actuals and "predict for prediction df to be transformed to ts for visuals
df_to_ts <- function(start_df, actual_predict) {
  end_ts <- start_df %>% 
    filter(key == actual_predict) %>% 
    select(index, value) %>% 
    read.zoo() 
}

df.act <- ts_to_df(zoo_count_rides.train) %>% add_column(key = "actual")
df.test <- ts_to_df(zoo_count_rides.test) %>% add_column(key = "predict") %>% head(h)
df.fc <- ts_to_df(zoo_count_rides.fc) %>% add_column(key = "predict")
#RESULT AS DF
df.result <- rbind(df.act, df.fc)

ts.act <- df_to_ts(df.result, "actual")
ts.fc <- df_to_ts(df.result, "predict")
ts.test <- df_to_ts(df.test, "predict")

#RESULT AS TS
ts.result.tmp <- merge(ts.act, ts.fc)
ts.result <- merge(ts.result.tmp, ts.test)
names(ts.result) <- c("Actual", "Prediction", "Test")

#add fit from the model to the results
ts.fit <- data.frame(df.act, fc.fit$fitted) %>% 
  select("index","fc.fit.fitted") %>%
  na.omit() %>% 
  read.zoo()
names(ts.fit) <- c("index", "Fit")

#RESULT EXTENDED AS TS
ts.extended <- merge(ts.result, ts.fit)
names(ts.extended) <- c("Actual", "Prediction", "Test", "Fit")

# Accuracy
fit.accuracy <- accuracy(fc.fit) %>% data.frame()
fit.accuracy

fc.accuracy <- accuracy(fc.fit$mean, x = df.test$value) %>% data.frame()
fc.accuracy

dygraph(ts.extended) %>% 
  dyRangeSelector() %>% 
  dyOptions(drawPoints = F, pointSize = 2, colors = RColorBrewer::brewer.pal(4, "BrBG")[c(4, 2, 3, 1)]) %>% 
  dyUnzoom() %>% 
  dyCrosshair(direction = "vertical") %>% 
  dyLegend(width = 400)

#
# RESIDUALS
#

checkresiduals(fit)

