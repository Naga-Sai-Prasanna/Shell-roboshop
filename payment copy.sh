#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/robpshop"
LOGS_FILE="/$LOGS_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.prasanna.fun
MYSQL_HOST=mysql.prasanna.fun

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



dnf install python3 gcc python3-devel -y
VALIDATE $? "installation of python"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
  echo "adding user"
  useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
  VALIDATE $? "useradding"
else
  echo -e  "user is already existed ....$Y SKIPPING $N"
fi  

mkdir -p /app
VALIDATE $? "creating app dir"


curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "downloading nodejs"

cd /app 
VALIDATE $? "Moving to app dir"

rm -rf /app/*
VALIDATE $? "removing the data"

unzip /tmp/payment.zip
VALIDATE $? "unzip the code"


pip3 install -r requirements.txt
VALIDATE $? "downloading dependencies"


cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
VALIDATE $? "creating systemctl service"


systemctl daemon-reload
VALIDATE $? "reload"

systemctl enable payment 
systemctl start payment
VALIDATE $? "enabling and start"




