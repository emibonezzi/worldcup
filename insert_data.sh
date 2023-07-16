#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE teams,games")"
echo "$($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1")"
echo "$($PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1")"

#FILL TEAMS TABLE

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_TEAM="$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")"
  OPPONENT_TEAM="$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")"
  

  #if WINNER not found
  if [[ -z $WINNER_TEAM ]]
  then
  #skip headers
    if [[ $WINNER != "winner" ]] 
    then
    #insert into db
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")"
    fi
   #else WINNER found 
  fi

  #if OPPONENT not found
  if [[ -z $OPPONENT_TEAM ]]
  then
  #skip headers
    if [[ $OPPONENT != "opponent" ]] 
    then
    #insert into db
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")"
    fi
  fi   

  

done

#FILL GAMES TABLE

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

if [[ $WINNER != "winner" ]] 
  then
  #FIND WINNER_ID AND OPPONENT_ID
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  echo "$($PSQL "INSERT INTO games(winner_id, opponent_id, year, round, winner_goals, opponent_goals) VALUES($WINNER_ID, $OPPONENT_ID, $YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS)")"
fi

done


echo "$($PSQL "SELECT COUNT(*) FROM teams")"
echo "$($PSQL "SELECT COUNT(*) FROM games")"