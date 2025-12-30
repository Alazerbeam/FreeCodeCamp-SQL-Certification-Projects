#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# search username in database
USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")

if [[ ! -z $USER_ID ]]
then
  # search all relavent information in database
  GAME_INFO=$($PSQL "select count(*), min(num_guesses) from games where user_id = $USER_ID")
  echo $GAME_INFO | sed -E 's/\|/ /' | while read NUM_GAMES BEST_GUESSES
  do
    echo "Welcome back, $USERNAME! You have played $NUM_GAMES games, and your best game took $BEST_GUESSES guesses."
  done
else
  # add user to database and save the user_id
  INSERT_USER=$($PSQL "insert into users(username) values ('$USERNAME')")
  USER_ID=$($PSQL "select user_id from users where username = '$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

NUM_GUESSES=1

until [[ $GUESS -eq $NUMBER ]]
do
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  fi
  read GUESS
  (( NUM_GUESSES++ ))
done

echo "You guessed it in $NUM_GUESSES tries. The secret number was $NUMBER. Nice job!"

# add game to database
INSERT_GAME=$($PSQL "insert into games(user_id, num_guesses) values ($USER_ID, $NUM_GUESSES)")