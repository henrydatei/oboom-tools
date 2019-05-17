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

i=0
curl -s -d "token=$session" "https://api.oboom.com/1/remote/lsall" >> upload-state.txt
state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")

while [ "$state" != "null" ]; do
  url=$(cat upload-state.txt | jq -r ".[3] | .[$i].url")
  echo "$url"
  i=$(($i + 1))
  state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")
done

rm upload-state.txt
