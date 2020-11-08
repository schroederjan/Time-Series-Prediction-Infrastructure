
#PACKAGES
library(RPostgres)
library(DBI)
library(yaml) #for sourcing password from local file
library(dplyr)
library(xts)
library(forecast) #for installation on fresh Ubuntu prob. needed "libcurl4-openssl-dev" installed
library(dygraphs)
library(timetk)
library(tibble)
library(purrr)
library(rlang)
library(tibbletime)
library(lubridate)
library(caTools)
library(glue) #for calling objects inside characters "this {object}"

#SOURCES
#get password information from yml file
config = yaml.load_file("SECURITY/config.yml")

#FUNCTIONS
import_data_from_db <- function(con, time_config, index_config, value_config, table_config){
  data.tmp <- dbGetQuery(con, statement = glue("
SELECT time_bucket_gapfill('{time_config} minutes', {index_config}, '2016-01-01 00:00:00','2016-01-31 23:59:59') AS index,
{value_config} AS value
FROM {table_config}
WHERE ST_Distance(pickup_geom, ST_Transform(ST_SetSRID(ST_MakePoint(-74.0113, 40.7075),4326),2163)) < 400 
  AND pickup_datetime < '2016-02-01'
GROUP BY index
ORDER BY index
           ;"))
  data <- data.tmp %>% 
    mutate(value = as.numeric(value))
  return(data)
}
prepare_for_prediction <- function(data){
  ts_data <- data %>% 
    mutate(index = as.POSIXct(x = data$index, tz = "", format = "%Y-%m-%d %H:%M:%S")) %>% 
    select(c("index", "value")) %>% 
    data.frame() %>% 
    read.zoo()
  return(ts_data)
}
prepare_for_visual <- function(fc.fit, ts_data.train, ts_data.test){
  
  
  # create future dates for the time horizon predicted
  idx <- ts_data.train %>%
    tk_index() %>%
    tk_make_future_timeseries(length_out = h)
  
  # Retransform values
  ts_data.fc <- tibble(
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
  
  df.act <- ts_to_df(ts_data.train) %>% add_column(key = "actual")
  df.test <- ts_to_df(ts_data.test) %>% add_column(key = "predict") %>% head(h)
  df.fc <- ts_to_df(ts_data.fc) %>% add_column(key = "predict")
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
  fc.accuracy <- accuracy(fc.fit$mean, x = df.test$value) %>% data.frame()
  result.accuracy <- bind_rows(fit.accuracy, fc.accuracy)
  
  function.list <- list(result.accuracy, ts.extended)
  
  # FUNCTION RESULT AS LIST
  return(function.list)
  
}
visualize_ts <- function(ts){
  dygraph_result <- dygraph(ts) %>% 
    dyRangeSelector() %>% 
    dyOptions(drawPoints = F, pointSize = 2, colors = RColorBrewer::brewer.pal(4, "BrBG")[c(4, 2, 3, 1)]) %>% 
    dyUnzoom() %>% 
    dyCrosshair(direction = "vertical") %>% 
    dyLegend(width = 400)
  return(dygraph_result)
}

#CONFIGURATIONS
#--------------------------------------------------------------------------------
# database configurations
con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'nyc_data', 
                 host = 'localhost',
                 port = 5432,
                 user = 'postgres',
                 password = config$TIMESCALEDB$PW)
#--------------------------------------------------------------------------------
# time horizon for prediction and train/test split window
# h = input variable in SHINY
h <- 48
#--------------------------------------------------------------------------------
# import configurations
time_config = "60" #choose input for time_bucket_gapfill function from timescaledb in minutes
index_config = "pickup_datetime" #choose a table that contains the index
value_config = "COUNT(*)" #choose the function/table that contains the values
table_config = "rides" #choose table in database

#FORECAST
data <- import_data_from_db(con, time_config, index, value, table)

# split into train-test data according to prediction horizon
data_train <- head(data, round(length(data) - h))
data_test <- tail(data, h)

# statistical test
Acf(data_train$value)

# transform data into time-series
ts_data.test <- prepare_for_prediction(data_test)
ts_data.train <- prepare_for_prediction(data_train)

# forecast model
fit <- nnetar(ts_data.train)
fc.fit <- forecast(fit, h = h, PI = T, npaths = 100)

# prepare results for visuals
list.data.visual <- prepare_for_visual(fc.fit, ts_data.train, ts_data.test)
ts.extended <- list.data.visual[[2]] 
df.accuracy <- list.data.visual[[1]] 

# RESIDUALS & ACCURACY
checkresiduals(fit)
df.accuracy

#VISUALIZATION
visualize_ts(ts.extended)


