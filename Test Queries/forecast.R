
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

#FORECAST
data <- import_data_from_db(con, time_config, index, value, table)

#overview.data <- prepare_for_prediction(data)
#dygraph(overview.data)

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


