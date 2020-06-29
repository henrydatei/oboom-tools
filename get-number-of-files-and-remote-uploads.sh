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

numberOfFiles=$(curl -s -d "token=$session" "https://api.oboom.com/1/tree" | jq '.[1] | .[] | select(.type == "file") | select(.parent != "1C")' | jq -s length)
numberOfRemoteUploads=$(curl -s -d "token=$session" "https://api.oboom.com/1/remote/lsall" | jq '.[3] | length')

echo "Number of Files (without Trash): \033[32m$numberOfFiles\033[0m"
echo "Number of Remote Uplaods: \033[32m$numberOfRemoteUploads\033[0m"
