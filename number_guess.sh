#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo "Enter your username:"
read USERNAME

OLDRESULTS=$($PSQL "SELECT * FROM players WHERE username = '$USERNAME';")

if [[ $OLDRESULTS ]]
then
  echo "$OLDRESULTS" | sed 's/|/ /g' | while read -r ID USERNAME GAMES_PLAYED BEST_GAME;
    do
      echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    done
else
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
fi

GUESSES=0
SECRETNUM=$((RANDOM % 1000 + 1))
echo "Guess the secret number between 1 and 1000:"

while [[ $GUESS != $SECRETNUM ]]
do
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS > $SECRETNUM ]]
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS < $SECRETNUM ]]
    then
      echo "It's higher than that, guess again:"
    fi
    GUESSES=$(($GUESSES + 1))
  fi
done

echo "You guessed it in $GUESSES tries. The secret number was $SECRETNUM. Nice job!"

if [[ $OLDRESULTS ]]
then
  NEWTOTAL=$(($GAMES_PLAYED + 1))
  UPDATE=$($PSQL "UPDATE players SET games_played = $NEWTOTAL WHERE username = '$USERNAME'")
  if [[ $GUESSES < $BEST_GAME ]]
  then
    UPDATE_HIGHSCORE=$($PSQL "UPDATE players SET best_game_guesses = $GUESSES WHERE username = '$USERNAME'")
  fi
else
  INSERT=$($PSQL "INSERT INTO players(username, games_played, best_game_guesses) VALUES('$USERNAME', 1, $GUESSES)")
fi
