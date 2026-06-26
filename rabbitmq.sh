#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/robpshop"
LOGS_FILE="/$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD

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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "rabbitmq repo file"

dnf install rabbitmq-server -y
VALIDATE $? "install rabbitmq"


systemctl enable rabbitmq-server

VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server
VALIDATE $? "start rabbitmq"


rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "setting username and pass"