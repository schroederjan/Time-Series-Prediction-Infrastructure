# Time Series Prediction Infrastructure

## Table of contents
* [Introduction](#introduction)
* [Background](#background)
* [Dependencies](#dependencies-&-technologies)
* [Features](#parts)
* [Local Setup](#local-setup)
* [Status](#status)
* [Inspiration](#inspiration)
* [Contact](#contact)

## Introduction

For a more detailed tutorial of how this infrastructure works visit my [Website](http://schroederjan.com/). `COMING SOON`

## Background

![](man/featured.png)

## Dependencies & Technologies

* [`R`]() as scripting language for data preparation and prediction algorithms based on `R`. Also used for the user interface, a `Shiny` application.
* [Python]() as scripting language for `Airflow` and prediction algorithms based on `Python`.
* [Shiny Server]() as `R` engine that will run the scripts and the user interface, a `Shiny` application.
* [TimescaleDB]() as time series database build on top of Postgres that will hold all data. `TimescaleDB`
* [Airflow]() as scheduling work-flow manager to coordinate the whole infrastructure. `Airflow`

## Parts
* [Step 1] Connect to different data sources using `R`.
* [Step 2] Prepare and clean the data, then store it to the time series database using `R`.
* [Step 3] Run Prediction and other algorithms on the data stored in the `TimescaleDB` using `R` and `Python`.
* [Step 4] Visualize the data and results for insight using `R` in `Shiny`.

## Local Setup

`COMING SOON`

## Status
The project is _in progress_ and will be expanded with new features repeatedly.
My goal is it to build a state of the art "Time Series Prediction Infrastructure" that others can customize or expand at will to their needs.

### To-do list:

`COMING SOON`

## Inspiration

* [Business Science University](https://university.business-science.io/) for `Shiny`
* [Rob J Hyndman](https://robjhyndman.com/publications/) for `R`
* [Timescale](https://www.timescale.com/) for `TimescaleDB`
* [Apache Airflow](https://airflow.apache.org/) for `Airflow`
* [Xmind](https://www.xmind.net/xmind2020/) for the tool of my illustrations.

## Contact
Created by [Jan Schroeder](https://www.schroederjan.com/) - feel free to contact me!

