#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# for each entry in games.csv
echo $($PSQL "truncate table games, teams")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # ignore titles of columns
  if [[ $YEAR == year ]]
  then
    continue
  fi
  # check if winner and opponent exist in teams table
  # if not, add them
  WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
  OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
  if [[ -z $WINNER_ID ]]
  then
    ADD_WINNER_RESULT=$($PSQL "insert into teams(name) values ('$WINNER')")
    WINNER_ID=$($PSQL "select team_id from teams where name = '$WINNER'")
  fi
  if [[ -z $OPPONENT_ID ]]
  then
    ADD_OPPONENT_RESULT=$($PSQL "insert into teams(name) values ('$OPPONENT')")
    OPPONENT_ID=$($PSQL "select team_id from teams where name = '$OPPONENT'")
  fi

  # now add game info
  ADD_GAME_RESULT=$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) \
  values ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

done