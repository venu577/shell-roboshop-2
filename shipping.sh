#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shellscript-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

# check the USER has root priveleges or not
if [ $USERID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

echo "please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD
# validate functions takes input as exit status, what command they tried to install
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing Maven and java"

id roboshop
if [ $? -ne 0 ]
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "creating roboshop user"
else
    echo -e "$Y roboshop user is already created $N" | tee -a $LOG_FILE
fi
    # Check if roboshop user exists, if not create it
    # If it exists, skip user creation

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading shpping zip file"

rm -rf /app/* &>>$LOG_FILE
cd /app
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping zip file"

     
mvn clean package &>>$LOG_FILE
VALIDATE $? "building maven package"
# The above command will create a jar file in the target directory
# Move the jar file to the current directory and rename it to shipping.jar

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "moving jar file to current directory"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "copying shipping service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "reloading systemd daemon"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "enabling shipping service"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "restarting shipping service"

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

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE
# The above command will import the schema and data into the MySQL database


