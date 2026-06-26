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

dnf module disable redis -y
VALIDATE $? "disabling redis"

dnf module enable redis:7 -y
VALIDATE $? "enabling redis"

dnf install redis -y
VALIDATE $? "installation of redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e  '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "allowing remote connections" 


systemctl enable redis  &>> $LOGS_FILE
systemctl start redis
VALIDATE $? "enable and start of the redis" | tee -a  $LOGS_FILE

