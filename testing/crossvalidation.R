
#PACKAGES
source("modules/packages.R")

#SOURCES
#get password information from yml file
config = yaml.load_file("modules/config.yml")

#FUNCTIONS
source("modules/functions.R")

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

#DATA
data <- import_data_from_db(con, time_config, index, value, table)

split_percent <- 0.2
split_ts_data <- function(data, split_percent){
  h <- floor(nrow(data)*split_percent)
  data_train <- head(data, round(length(data) - h))
  data_test <- tail(data, h)
  ret.list <- list(data_train, data_test)
  return(ret.list)
}

####
#ONE ---------------------------------------------------------------------------
####
#split
data_train_1 <- split_ts_data(data, split_percent)[[1]] %>% mutate(key = "actual")
data_test_1 <- split_ts_data(data, split_percent)[[2]] %>% mutate(key = "test")
#data_1 <- bind_rows(data_train_1, data_test_1)

#to ts
ts_data.test_1 <- prepare_for_prediction(data_test_1)
ts_data.train_1 <- prepare_for_prediction(data_train_1)

#predict
fit_1 <- nnetar(ts_data.train_1)
fc.fit_1 <- forecast(fit_1, h = nrow(data_test_1), PI = F, npaths = 100)



#
# FUNCTION
#


#visual
list.data.visual_1 <- prepare_for_visual(fc.fit_1, ts_data.train_1, ts_data.test_1)
ts.extended_1 <- list.data.visual[[2]] 
df.accuracy_1 <- list.data.visual[[1]] 

####
#TWO ---------------------------------------------------------------------------
####
data_train_2 <- split_ts_data(data_train_1, split_percent)[[1]] %>% mutate(key = "actual")
data_test_2 <- split_ts_data(data_train_1, split_percent)[[2]] %>% mutate(key = "test")
#data_2 <- bind_rows(data_train_2, data_test_2)

####
#THREE -------------------------------------------------------------------------
####
data_train_3 <- split_ts_data(data_train_2, split_percent)[[1]] %>% mutate(key = "actual")
data_test_3 <- split_ts_data(data_train_2, split_percent)[[2]] %>% mutate(key = "test")
#data_3 <- bind_rows(data_train_3, data_test_3)



#merge results
data_merge.tmp <- merge(data_1, data_2, by="index", all=T)
data_merge <- merge(data_merge.tmp, data_3, by="index", all=T)
names(data_merge) <- c("index", "value.x",  "key.x", "value.y", "key.y", "value.z", "key.z")
str(data_merge)



