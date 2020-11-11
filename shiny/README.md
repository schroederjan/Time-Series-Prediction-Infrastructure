# Time Series Prediction Infrastructure - Shiny
> This is part 2 of the deep dive into the project

## Table of contents
* [Introduction](#introduction)
* [Dependencies](#dependencies)
* [Walkthrough](#walkthrough)
* [Contact](#contact)

## Introduction
`COMING SOON`

### Objectives

`COMING SOON`

X. We are ready to go to the next part of the project -> [`Airflow`]()

### Application
* [`app.R`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/shiny/app.R)

### Modules
* [`loadModule.R`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/shiny/modules/loadModule.R) for loading data from the database.
* [`crossvalidationModule.R`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/shiny/modules/crossvalidationModule.R) for applying a crossvalidation test to the data.
* [`predictionModule.R`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/shiny/modules/predictionModule.R) for running prediction models on the data.

### Other Scripts
* [`functions.R`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/shiny/modules/functions.R) holding all functions that need to be loaded by the app
* [`packages.R`](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/shiny/modules/packages.R) holding all packages that need to be loaded by the app

## Dependencies
`COMING SOON`

### Configuration Files
For security and adjustability reasons I saved the database password in a yaml file called: "config.yml"
The file is not present in this repo but is necessary for it to work. 
Please place a file with the name "config.yml" and the following content together with the scripts:
```bash
TIMESCALEDB: 
  PW: <YOUR PASSWORD>
```

## Walkthrough
### loadModule
![](man/featured_1.png)

### crossvalidationModule
![](man/featured_2.png)

### predictionModule
![](man/featured_3.png)

## Contact
Created by [Jan Schroeder](https://www.schroederjan.com/) - feel free to contact me!

