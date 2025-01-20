#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

SERVICES_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo -e "Welcome to My Salon, how can I help you?\n"

  SERVICES_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  SERVICE_CHOICE_MENU
}

SERVICE_CHOICE_MENU() {
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    SERVICES_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

    if [[ -z $SERVICE_ID ]]; then
      SERVICES_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE

      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

      if [[ -z $CUSTOMER_NAME ]]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      fi

      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

      echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')?"
      read SERVICE_TIME

      INSERT_CUSTOMER_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi
  fi
}


## CALL SERVICE FUNCTION
SERVICES_MENU
