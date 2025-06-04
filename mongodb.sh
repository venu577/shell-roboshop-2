#!/bin/bash

source ./common.sh
app_name="mongodb"

check_root
# Check if the script is run with root access

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongodb server"

systemctl enable mongod &>>$LOG_FILE
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "enabling and starting mongodb service"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
VALIDATE $? "updating mongodb config file"

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongodb service"

echo -e "$G mongodb installation is $Y completed $N" | tee -a $LOG_FILE

print_time
# Print the total time taken for script execution