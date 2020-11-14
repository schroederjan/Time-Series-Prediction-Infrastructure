# Time Series Prediction Infrastructure
> This is the main page of the deep dive into the project

### ATTENTION
To successfully set up this project you need to know at least basics of:

* R
* Python
* Linux (for cloud setup)
* AWS EC2 (for cloud setup)
* PostgreSQL (for Part I)
* Docker (for Part I + III)
* Airflow (for Part III)
* How to run scripts from the command line

## Table of contents
* [Introduction](#introduction)
* [Background](#background)
* [Technologies](#technologies)
* [Dataflows](#dataflows)
* [Local Setup](#local-setup)
* [Cloud Setup](#cloud-setup)
* [Status](#status)
* [Inspiration](#inspiration)
* [Contact](#contact)

## Introduction

The project provides a concept for a scalable infrastructure approach to modern analytics for time series data, either locally or on the cloud. The infrastructure consists of five core technologies, which are all open source. The strength lies within the unique characteristics of the time-series database 'TimescaleDB', the web-application framework 'Shiny', and the workflow management system 'Airflow'. All three tied together by the scripting languages 'R' & 'Python', provide everything to power time-series predictive analytics of small departments to a whole company. The concept can adapt and scale along with the needs of small and big data.

For a more detailed tutorial of how this infrastructure works in practice visit my [Website](http://schroederjan.com/). `COMING SOON`

## Background
The core idea originally started when working on the Capstone Project for my Data Engineering Nanodegree at Udacity. At this point it grew into a bigger concept that connects Data Engineering (Infrastructure) and Data Science (Application).

When working with time-series data I prefer to work on as many transformations as possible to find the optimal input into prediction algorithms. Either daily, weekly, monthly or even bigger aggregates could deliver THE insight needed. To achieve this, normally I was writing on transformation scripts that would, after a while of calculation, spit out various csv files in a folder, which I then had to access in my analytics framework of choice for further crunching. 

After working with PostgreSQL and Cassandra NoSQL databases I was always missing the 'right' approach to time-series data. When I found 'TimescaleDB' though, I saw the chance to speedup time-series analytics and create a perfect back-end for shiny (no pun intended ;)) web-applications. With its built-in time-series aggregation functions on-demand transformation became possible. No more pre-transforming data needed, just plug your Data Science application of choice (or build one) and get started.

For the final touch I added the workflow management engine 'Aiflow', with which we can run scheduled predictions, ETL commands, or even manage whole cloud infrastructures in a monitored and structured way.

Below you can have a look at how this project is set up.
Each of the core technologies has a sub-readme linked to it for a deep dive into how to get started. 

![](man/featured.png)

## Technologies

### Scripting Languages
* [`R`](https://www.r-project.org/) as scripting language for data preparation and prediction algorithms based on `R`. Also used for the user interface, a `Shiny` application.
* [`Python`](https://www.python.org/) as scripting language for `Airflow` and prediction algorithms based on `Python`.

### Core Technologies
* [`TimescaleDB`](https://www.timescale.com/) as time series database build on top of Postgres that will hold all data. `TimescaleDB`
* [`Shiny Server`](https://rstudio.com/products/shiny/shiny-server/) as `R` engine that will run the scripts and the user interface, a `Shiny` application.
* [`Airflow`](https://airflow.apache.org/) as scheduling work-flow manager to coordinate the whole infrastructure. `Airflow`

## Dataflows
1. Connect to your data source using `R`.
2. Prepare and clean the data, then store it into the time-series database using `Python`.
3. Run predictions and other algorithms on the data stored in the `TimescaleDB` using `R` or `Python`.
4. Visualize the data and results for insight using `R` in `Shiny`.

## Local Setup
* `Part I` - Get the back-end database `TimesceleDB` running and move your data into it [here](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/tree/main/timescaledb).
* `Part II` - Get the front-end data application server `Shiny` up and running [here](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/tree/main/shiny).
* OPTIONAL `Part III` - Get your workflow engine `Airflow` up and running [here](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/tree/main/airflow). `COMING SOON`

## Cloud Setup
To avoid costs, an AWS EC2 instance with an Ubuntu image is all we need to move this project to the cloud.
I will go into details how to do it manually [here](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/tree/main/cloud).

## Status
The project is _in progress_ and will be expanded with new features regularly.
My goal is it to build a state of the art "Time Series Prediction Infrastructure" that others can customize or expand at will to their needs.

### To-do list:

* OPTTIONAL Part 3: Airflow

## Inspiration

* [Udacity's Data Engineering Nanodegree](https://www.udacity.com/course/data-engineer-nanodegree--nd027) for learning Data Engineering
* [Business Science University](https://university.business-science.io/) for `Shiny` and `R` for Data Science
* [Rob J Hyndman](https://robjhyndman.com/publications/) for statistics with `R` 
* [Timescale](https://www.timescale.com/) for `TimescaleDB`
* [Apache Airflow](https://airflow.apache.org/) for `Airflow`
* [Xmind](https://www.xmind.net/xmind2020/) for the tool of my illustrations.

## Contact
Created by [Jan Schroeder](https://www.schroederjan.com/) - feel free to contact me!

