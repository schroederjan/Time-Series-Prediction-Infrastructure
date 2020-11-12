# Time Series Prediction Infrastructure - TimescaleDB
> This is part 1 of the deep dive into the project

## Table of contents
* [Introduction](#introduction)
* [Dependencies](#dependencies)
* [Walkthrough](#walkthrough)
* [Contact](#contact)

## Introduction
As the heart of every data analytics platform there should be a proper place to store the data.
In this project we will use one of the more and more popular "Time Series" databases that fits our goal to perform time-series prediction perfectly.

### Objectives
1. We want to get some sample data
2. We want to set up a database instance (`TimescaleDB`)
3. We want to create tables
4. We want to load the data into the tables
5. Done! We are ready to go to the next part of the project -> [`Shiny Server`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/tree/main/shiny)

### Data
In general you could use any time-series data, however, when you do not want to change the scripts of this project you can stick with the sample data. The sample data is from the TimescaleDB tutorial in their documentation and can be found [here](https://docs.timescale.com/latest/tutorials/tutorial-hello-timescale)

* Sample Data: Yellow Taxi Cab Data
* Origin: New York City Taxi and Limousine Commission (NYC TLC)
* Time Frame: 2016
* Size: 1.7 GB

### Tables
```bash
nyc_data=# \dt
              List of relations
 Schema |      Name       | Type  |  Owner   
--------+-----------------+-------+----------
 public | payment_types   | table | postgres
 public | rates           | table | postgres
 public | rides           | table | postgres
```

### Scripts
* [`download_sample_data.py`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/timescaledb/download_sample_data.py) Script to get the data
* [`sql_queries.py`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/timescaledb/sql_queries.py) List of all SQL commands needed
* [`create_tables.py`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/timescaledb/create_tables.py) Script to create the DB environment
* [`etl.py`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/timescaledb/etl.py) Script to copy the data into the DB

## Dependencies
### TimescaleDB
To use this part of the project an up and running `TimescaleDB` instance is needed.
In my case I use the `Docker` image, that includes the Postgis extension, maintained by Timescale, which can be found [here](https://hub.docker.com/r/timescale/timescaledb-postgis/). 
If you want to learn more about how to get started with `TimescaleDB` you find more details on their official page [here](https://docs.timescale.com/latest/getting-started).

Once `TimescaleDB` is running you need to create a new database with the name `nyc_data`, using the following psql command provided by PostgreSQL.

Make sure you have `psql` installed on your system. 
It comes with a standard PostgreSQL installation you can find [here](https://www.postgresql.org/download/), or you install the `psql` client like this:

```bash
#install postgres client
sudo apt-get install postgresql-client
```

```bash
#log into your TimescaleDB instance
psql -h localhost -U postgres

#create a new database
CREATE DATABASE nyc_data;
```
Now you should be ready to run the scripts from this part of the project.

### Configuration Files
For security and adjustability reasons I saved the database configurations in a separate file called: "dwh.cfg"
The file is not present in this repo but is necessary for it to work. 
Please place a file with the name "dwh.cfg" and the following content together with the scripts:
```bash
[TIMESCALEDB]
#provides the database information for the scripts
#does not need quotes
HOST=localhost
DB_NAME=nyc_data
DB_USER=postgres
DB_PASSWORD=<YOUR PASSWORD>
DB_PORT=5432
```

## Walkthrough
### Objective 1 (Getting the data...)
For simplification I created a script to download and extract the sample data, just run [download_sample_data.py](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/timescaledb/download_sample_data.py)

```bash
#cd into the file location of the repo and run in your command line
python download_sample_data.py
```

The dataset file "nyc_data_rides.csv" should appear in the same directory.
(You can also manualy download and extract the data from [here](https://timescaledata.blob.core.windows.net/datasets/nyc_data.tar.gz))

### Objective 2 (Get the database up and running...)
Please check: [Dependencies](#dependencies)

### Objective 3 (Creating tables...)
Now we have a running database instance and data but no tables to copy it into. 
Let us change that.
```bash
#cd into the file location of the repo and run in your command line
python create_tables.py
```
This should be quite fast. Now we have our tables.

### Objective 4 (Copying tables...)
Alright, we have data, a database and tables in it. Now it is time to copy the data into the tables!
```bash
#cd into the file location of the repo and run in your command line
python etl.py
```
This should take a while. The script is copying the 1.7 GB data into the table.

### Objective 5 (Done!)
Let's continue with the next part of the project  -> [`Shiny Server`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/tree/main/shiny)

## Contact
Created by [Jan Schroeder](https://www.schroederjan.com/) - feel free to contact me!

