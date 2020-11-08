#
# FUNCTIONS USED IN MODULES
#

# to simplify the sql interface to the timescaledb via shiny module
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

# to prepare the data before it goes into the prediction models
prepare_for_prediction <- function(data){
  ts_data <- data %>% 
    mutate(index = as.POSIXct(x = data$index, tz = "", format = "%Y-%m-%d %H:%M:%S")) %>% 
    select(c("index", "value")) %>% 
    data.frame() %>% 
    read.zoo()
  return(ts_data)
}

# to prepare the results of the prediction modules for visualization
prepare_for_visual <- function(fc.fit, ts_data.train, ts_data.test, h){
  
  
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

# to keep the customized dygraph function small 
visualize_ts <- function(ts){
  dygraph_result <- dygraph(ts) %>% 
    dyRangeSelector() %>% 
    dyOptions(drawPoints = F, pointSize = 2, colors = RColorBrewer::brewer.pal(4, "BrBG")[c(4, 2, 3, 1)]) %>% 
    dyUnzoom() %>% 
    dyCrosshair(direction = "vertical") %>% 
    dyLegend(width = 400)
  return(dygraph_result)
}