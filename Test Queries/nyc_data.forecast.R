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