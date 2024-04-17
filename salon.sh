#! /bin/bash

#connect to salon database
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# truncate old tables
#TRUNCATE TABLE customers, appointments RESTART IDENTITY

#function to display list of the services
SERVICES_MENU () {
  # Print 1st argument if given
  if [[ $1 ]]
  then
    echo -e "\n$1"  
  fi

  #available services
  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")

  # display list of services in format <service_id>) <service>
  echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR NAME_SERVICE
  do
    #change color of ) in red check grep or sed
    echo "$SERVICE_ID) $NAME_SERVICE" | grep --color ')'
  done

  #input your choice
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]] 
  then
    SERVICES_MENU "I could not find that service. What would you like today?"   
  fi
}

#insert new customers
INSERT_NEW_CUSTOMER () {
  INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
}

CREATE_APPOINTMENT () {
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  # insert to appointments table
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # print message
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *//g').\n"
}

# Main Program Starts Here
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
SERVICES_MENU

# get customer's phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# query for customer name by phone
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]] 
then
  # if not exist in customers table, then ask for new customer name
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_NEW_CUSTOMER
fi

# ask for service time
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *//g')?"
read SERVICE_TIME

CREATE_APPOINTMENT