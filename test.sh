# #!/bin/bash

# # echo "please enter your name: "
# # read name

# # echo "$name is best girl"


# numbers=("a" "b" "c" "d" "n")  

# =${numbers[-1]}

# echo "the number is $last_value"



# my_array=("apple" "banana" "orange" "grape")

# # Access the last element
# last_value="${my_array[-1]}"

# echo "The last value is: $last_value"


#!/bin/bash
# number=$1
# if [ $number -gt 20 ]; then
#    echo "$number is greater than 20"

# elif [ $number -eq 20 ]; then
#     echo "$number is equal to  20"

# else
#    echo "$number is less than 20"

#  fi



# userid=$(id -u)
# if [ $userid -ne 0 ]; then
#   echo "please run this script as root user"
#   exit 1
# fi
# echo "installing nginx"
# dnf install nginx -y

# echo "removing nginx"
# dnf remove nginx -y

userid=$(id -u)
mkdir -p $LOGS_FOLDER
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDER/$0.log"



 if [ $userid -ne 0 ]; then
   echo "please run this script with root access" | tee -a $LOGS_FILE
   exit 1
fi



VALIDATE(){
    if [ $1 -ne 0 ]; then
    echo "$2......failure". | tee -a $LOGS_FILE
    else
    echo "$2.....success". | tee -a $LOGS_FILE
    fi
}

dnf install nginx -y &>>$LOGS_FILE | tee -a $LOGS_FILE
VALIDATE $? "installing nginx"  | tee -a $LOGS_FILE

dnf remove nginx -y &>>$LOGS_FILE | tee -a $LOGS_FILE
VALIDATE $? "removing nginx" | tee -a $LOGS_FILE