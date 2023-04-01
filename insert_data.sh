#!/bin/bash




if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi




# Do not change code above this line. Use the PSQL variable above to query your database.




echo "$($PSQL "TRUNCATE games, teams")"




cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS 
do
  if [[ $YEAR != 'year' ]]; then
  #get team id from winner
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE teams.name='$WINNER'")
    
    #if not found
    if [[ -z $TEAM_ID ]]; then
    #insert missing winner
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT = 'INSERT 0 1' ]]; then
      #print inserted team
        echo Inserted into teams, $WINNER
      fi
      #get new team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE teams.name='$WINNER'")
    fi
    #get team_id from opponent
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE teams.name='$OPPONENT'")
    #if not found
    if [[ -z $TEAM_ID ]]; then
      #insert opponent into teams(name)
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT = 'INSERT 0 1' ]]; then
      #print inserted team
        echo Inserted into teams, $OPPONENT
      fi
      #get new team_id 
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE teams.name='$OPPONENT'")
    fi
  
    #get winner_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE teams.name='$WINNER'")
    #get opponent_id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE teams.name='$OPPONENT'")
    #insert data into games
    INSERT_INTO_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_INTO_GAMES_RESULT='INSERT 0 1' ]]; then
      echo -e "Inserted into games: year,round,winner,opponent,winner_goals,opponent_goals\n \t\t\t$YEAR, $ROUND, $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS\n"
    fi
  fi
  
done
