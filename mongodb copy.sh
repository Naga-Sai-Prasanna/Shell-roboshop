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

cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGS_FILE
VALIDATE $? "copying mongo repo" | tee -a  $LOGS_FILE

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "mongodb installation" | tee -a  $LOGS_FILE

systemctl enable mongod  &>> $LOGS_FILE
systemctl start mongod
VALIDATE $? "enable and start of the mongodb" | tee -a  $LOGS_FILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connections" | tee -a  $LOGS_FILE

systemctl restart mongod
VALIDATE $? "restarted mongodb" | tee -a  $LOGS_FILE



