
library(RPostgres)
library(DBI)
library(yaml) #for sourcing password from local file

#
# LOAD FROM TIMESCALE DB
#

#get aws information from yml file
config = yaml.load_file("SECURITY/config.yml")

#Configarations
con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'nyc_data', 
                 host = 'localhost',
                 port = 5432,
                 user = 'postgres',
                 password = config$TIMESCALEDB$PW)

#
# QUERIES
#

#simple quick look
dbGetQuery(con, statement = "
SELECT *
FROM rides
LIMIT 5
           ;")

#much faster with this query directly in the database then import and manually query!!!
dbGetQuery(con, statement = "
SELECT date_trunc('day', pickup_datetime) as day, COUNT(*)
FROM rides
GROUP BY day 
ORDER BY day
           ;")

dbGetQuery(con, statement = "
SELECT date_trunc('day', pickup_datetime) as day,
SUM(passenger_count) as passengers
FROM rides 
GROUP BY day 
ORDER BY day
           ;")

dbGetQuery(con, statement = "
SELECT time_bucket('1 minutes', pickup_datetime) as hour, count(passenger_count) as passengers 
FROM rides
GROUP BY hour
ORDER BY passengers DESC
           ;")

dbGetQuery(con, statement = "
SELECT time_bucket('1 minutes', pickup_datetime) as hour, count(passenger_count) as passengers 
FROM rides
GROUP BY hour
ORDER BY passengers DESC
           ;")

#-- What is the daily average fare amount for rides with only one passenger for first 7 days?
dbGetQuery(con, statement = "
SELECT time_bucket('1 days', pickup_datetime) as time, avg(fare_amount)
FROM rides
WHERE passenger_count = 1
GROUP BY time
LIMIT 7
           ;")

#-- How many rides of each rate type took place in the month?
dbGetQuery(con, statement = "
SELECT rate_code, count(vendor_id) as trips
FROM rides
GROUP BY rate_code
ORDER BY rate_code
           ;")

#-- Better
dbGetQuery(con, statement = "
SELECT rates.description, count(vendor_id) as trips,
RANK () OVER (ORDER BY COUNT(vendor_id) DESC) AS trip_rank
FROM rides
JOIN rates ON rides.rate_code = rates.rate_code
GROUP BY rates.description
ORDER BY trip_rank
           ;")

#-- For each airport: num trips, avg trip duration, avg cost, avg tip, avg distance, 
#min distance, max distance, avg number of passengers
dbGetQuery(con, statement = "
SELECT rates.description, count(vendor_id) as num_trips,
avg(dropoff_datetime - pickup_datetime) as avg_duration,
avg(total_amount) as avg_amount,
avg(tip_amount) as avg_tip,
min(trip_distance) as min_dist,
max(trip_distance) as max_dist,
avg(passenger_count) as passengers
FROM rides
JOIN rates ON rides.rate_code = rates.rate_code
WHERE rides.rate_code IN (2,3)
GROUP BY rates.description
ORDER BY rates.description
           ;")

#POSTGIS Queries
#-- How many taxis pick up rides within 400m of Times Square on New Years Day, grouped by 30 minute buckets.
#-- Number of rides on New Years Day originating within 400m of Times Square, by 30 min buckets
#-- Note: Times Square is at (lat, long) (40.7589,-73.9851)
dbGetQuery(con, statement = "
SELECT time_bucket('30 minutes', pickup_datetime) AS thirty_min, 
COUNT (*) as count_near_location
FROM rides
WHERE ST_Distance(pickup_geom, ST_Transform(ST_SetSRID(ST_MakePoint(-73.9851,40.7589),4326),2163)) < 400
GROUP BY thirty_min
ORDER BY count_near_location DESC
           ;")

