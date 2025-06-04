#!/bin/bash

source ./common.sh
app_name="catalogue"
# This script installs the catalogue service for the Roboshop application
check_root
# Check if the script is run with root access
app_setup
# Call the app_setup function to create roboshop user and download the application code
nodejs_setup
# Call the nodejs_setup function to install Node.js and its dependencies
cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo file"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "installing mongodb shell"

STATUS=$(mongosh --host mongodb.newgenrobots.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
   if [ $STATUS -lt 0 ]
   then
       mongosh --host mongodb.newgenrobots.site </app/db/master-data.js &>>$LOG_FILE
       VALIDATE $? "Loading data into MongoDB"
    else
       echo -e "Data is already loaded .. $Y SKIPPING $N"
    fi
print_time
# Print the total time taken for script execution

   
