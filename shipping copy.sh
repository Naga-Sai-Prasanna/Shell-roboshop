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



dnf install maven -y
VALIDATE $? "installation of maven"

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


curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATE $? "downloading nodejs"

cd /app 
VALIDATE $? "Moving to app dir"

rm -rf /app/*
VALIDATE $? "removing the data"

unzip /tmp/shipping.zip
VALIDATE $? "unzip the code"


mvn clean package
VALIDATE $? "downloading dependencies"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "renaming"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "creating systemctl service"


systemctl daemon-reload
VALIDATE $? "reload"

systemctl enable shipping 
systemctl start shipping
VALIDATE $? "enabling and start"




dnf install mysql -y 
VALIDATE $? "Client installation"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities'
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql  | tee -a $LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql    | tee -a $LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql | tee -a $LOG_FILE
    VALIDATE $? "load  data"

else
   echo -e "data is loaded......$Y SKIPPING $N" | tee -a $LOG_FILE
fi 

systemctl restart shipping
VALIDATE $? "Restaring shipping"




