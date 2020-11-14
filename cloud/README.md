# Time Series Prediction Infrastructure - Cloud Setup
> This is the cloud setup page

## Table of contents
* [General](#general)
* [AWS EC2](#aws-ec2)
* [Setup Server](#setup-server)
* [Setup TimescaleDB](#setup-timescaledb)
* [Setup Shiny](#setup-shiny)
* [Setup Airflow](#setup-airflow)
* [Contact](#contact)

## General

When locally running the application is not enough and we want to go to the cloud I am working with Amazons AWS EC2 Services in this project.

Because there is no (not yet) AMI image available for this infrastructure, we will create a simple EC2 instance, setup the environment manually and then get one (or two) docker containers running. At the moment there is no fully automatic way to build this infrastructure.

## AWS EC2

I provide this [script](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/blob/main/cloud/aws-vm-ubuntu.sh) to create a temporary EC2 instance, which we can then SSH into. After everyting is done we can just press [ENTER] and the instance will be terminated. The script is a modified version of Michael Wittigs "AWS in Action", which you can find [here](https://github.com/AWSinAction/code2/blob/master/chapter04/virtualmachine.sh).

If you want a more permanent testing environment, please create your own instance with Ubuntu and at least 30GB storage. (free tier is possible)

### Security Group Settings
Make also sure that the following ports are open.

HTTP          80
HTTPS         443
TimescaleDB   5432
SSH           22
Shiny         3838

## Setup Server

After your EC2 instance is up and running please follow those steps:
```bash
#connect to the ec2 instance
ssh -i "yourkey.pem" yourinstanceadress.compute.amazonaws.com

#update & upgrade
sudo apt update
sudo apt upgrade -y

#install docker
#for more information you can check this link
#https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04

#after installing docker, enable docker on start-up (optional)
sudo systemctl enable docker

#install pip (for installing python packages)
sudo apt-get install libpq-dev python-dev
sudo apt install python3-pip
#install the pycopg2 package (needed for TimescaleDB etl)
sudo pip3 install psycopg2
```
Now the server should be ready for the next steps.

## Setup TimescaleDB
The cloud setup ist the same as with the local setup I use [here](https://github.com/AionosChina/Time-Series-Prediction-Infrastructure/tree/main/timescaledb#dependencies).

## Setup Shiny
For the `Shiny Server` setup you can follow the steps below.
Just make sure you are in your EC2 instance.

For more detailed information you can check [this](https://towardsdatascience.com/how-to-host-a-r-shiny-app-on-aws-cloud-in-7-simple-steps-5595e7885722?gi=1f050bdf41e6) website with a more detailed guide.
If you want to pick another version of `Shiny Server` you can check [here](https://rstudio.com/products/shiny/download-server/ubuntu/) and adjust accordingly below.

```bash
#Install R and Packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install r-base
sudo apt-get install r-base-dev

#you will need to install the following packages on a fresh server for some R package dependencies
sudo apt install libssl-dev
sudo apt install libcurl4-openssl-dev

#install shiny before installing the server
sudo R -e "install.packages('shiny')"

#Install Shiny Server
#always check up to date version on: https://rstudio.com/products/shiny/download-server/ubuntu/
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.14.948-amd64.deb
sudo gdebi shiny-server-1.5.14.948-amd64.deb

#restart the server on startup (optional)
sudo systemctl enable shiny-server

#manage rights for the server directories
sudo chmod 777 /srv/shiny-server
sudo chmod 777 /etc/shiny-server

#copy the application from this repo to the server
cd /srv/shiny-server/
git clone https://github.com/AionosChina/Time-Series-Prediction-Infrastructure.git

#configure the /etc/shiny-server/shiny-server.config file
sudo nano /etc/shiny-server/shiny-server.config

###
### shiny-server.config
###

# Define a server that listens on port 3838
# Instruct Shiny Server to run applications as the user "ubuntu"
run_as ubuntu;

server {
  listen 3838;

  # Define a location at the base URL
  location /Time-Series-Prediction-Infrastructure/shiny {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /srv/shiny-server/Time-Series-Prediction-Infrastructure/shiny;

    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;
    app_init_timeout 250;
  }
}

###
###
###

#save and done
```
Now the `Shiny Server` should host the application and you can visit it here:
http://<Public IPv4 DNS>:3838/Time-Series-Prediction-Infrastructure/shiny

## Setup Airflow

OPTIONAL `COMING SOON`

## Contact
Created by [Jan Schroeder](https://www.schroederjan.com/) - feel free to contact me!

