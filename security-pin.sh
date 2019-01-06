#!/bin/sh
if [ -f session.txt ]; then
  timestampnow=$(date +%s)
  timestampold=$(cat session.txt | cut -d "|" -f1)
  difference=$(echo "$timestampnow - $timestampold" | bc)
  if [ $difference -le 1800 ]; then
    #session-id is only 30 minutes = 1800 seconds valid.
    session=$(cat session.txt | cut -d "|" -f2)
  else
    echo "Your session-ID is not valid anymore. Please get a new one with login.sh"
    rm session.txt
    exit
  fi
else
  echo "File \033[32msession.txt\033[0m not found."
  echo "Please get a session-ID from login.sh"
  exit
fi

result=$(curl -s "https://www.oboom.com/1/pincode/is?token=$session")
errorcode=$(echo "$result" | jq -r '.[0]')
set=$(echo "$result" | jq -r '.[1]')
trys=$(echo "$result" | jq -r '.[2]')
if [ $errorcode -eq 200 ]; then
  if [ $set -eq 1 ]; then
    echo "Your security pin is set. You have \033[32m$trys\033[0m trys."
  else
    echo "Your security pin is not set. It has been sent to your e-mail. You have \033[32m$trys\033[0m."
  fi
else
  echo "There are problems. Errorcode \033[31m$errorcode\033[0m, Message: \033[31m$set\033[0m."
fi
