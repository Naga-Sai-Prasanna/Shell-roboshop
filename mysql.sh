#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/robpshop"
LOGS_FILE="/$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


mkdir -p $LOGS_FOLDER

if [ $USERID -ne 0 ]; then
 echo -e " $R please run the script with root access $N" | tee -a $LOGS_FILE
 exit 1
fi


VALIDATE(){

if [ $1 -ne 0 ]; then
   echo -e "$R $2 ... failure $N" | tee -a $LOGS_FILE
else 
  echo -e "$G $2 ... success $N" | tee -a $LOGS_FILE
fi

}

dnf install mysql-server -y
VALIDATE $? "mysql installation"

systemctl enable mysqld
VALIDATE $? "enabling the mysql service"

systemctl start mysqld 

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "set root pass"