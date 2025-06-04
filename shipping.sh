#!/bin/bash

source ./common.sh
app_name="shipping"
check_root

echo "please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

app_setup 
maven_setup
systemd_setup

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "installing mysql clinet"

mysql -h mysql.newgenrobots.site -uroot -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then 

    mysql -h mysql.newgenrobots.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.newgenrobots.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h mysql.newgenrobots.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "loading data into mysql"
else
    echo -e "MySQL schema and data $Y already exists $N" | tee -a $LOG_FILE
fi
    # The above command will check if the cities database exists, if not it will create it and import the schema and data
    # If it exists, it will skip the import
    # The above command will import the schema and data into the MySQL database  
systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "restarting shipping service"      

print_time

