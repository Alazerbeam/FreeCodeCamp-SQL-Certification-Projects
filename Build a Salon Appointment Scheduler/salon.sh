#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"
# $($PSQL "truncate table appointments, customers")

echo -e "\n~~ Hair Salon Appointment Scheduler ~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo $1
  fi

  # get and print the options
  echo "Welcome to the hair salon! What can I help you with?"
  OPTIONS="$($PSQL "select * from services")"
  NUM_OPTIONS="$($PSQL "select count(*) from services")"
  echo $OPTIONS | sed -E 's/ ([0-9]+)/\n\1/g' | sed 's/|/) /g'
  read SERVICE_ID_SELECTED

  # if not selected valid option
  if [[ ! $SERVICE_ID_SELECTED =~ [1-$NUM_OPTIONS] ]]
  then
    MAIN_MENU "Please select a valid service."
    return
  fi
  SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED")

  # if selected valid option, get phone
  echo "What's your phone number?"
  read CUSTOMER_PHONE

  # search for customer
  CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
  # if customer doesn't exist, ask for name and add to database
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo "First time here? Welcome! What's your name?"
    read CUSTOMER_NAME
    ADD_CUSTOMER=$($PSQL "insert into customers(phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE'")
  fi

  echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
  ADD_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU "hello"