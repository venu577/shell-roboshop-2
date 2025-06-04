#!/bin/bash

START_TIME=$(date +%s)
USERID=$(id -u)
# Check if the script is run with root access
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
#colours R is for error G is for success Y is for installation N is for normal text

LOGS_FOLDER="/var/log/shellscript-logs" 
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# Extract the script name without the extension
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
# Define the log file path
# Create the logs folder if it doesn't exist 
SCRIPT_DIR=$PWD

mkdir -p $LOGS_FOLDER
echo "script started executing at: $(date)" &>>$LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R error: run with root access $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$G you are running with root access $N" | tee -a $LOG_FILE
    fi
}

VALIDATE(){
    if [ $1 -eq 0 ]
    then 
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    else 
        echo -e "$2 is $R not success $N" | tee -a $LOG_FILE
        exit 1
    fi
}

print_time(){
    END_TIME=$(date +%s)
    TOTAL_TIME=$(( $END_TIME - $START_TIME ))
        
    echo -e "script execution completed successfully , $Y time taken : $TOTAL_TIME Sec $N"
}

