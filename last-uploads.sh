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
  state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")
  url=$(cat upload-state.txt | jq -r ".[3] | .[$i].url")
  if [ "$state" = "complete" ]; then
    name=$(cat upload-state.txt | jq -r ".[3] | .[$i].name")
    size=$(cat upload-state.txt | jq -r ".[3] | .[$i].size")
    item=$(cat upload-state.txt | jq -r ".[3] | .[$i].item")
    echo "\033[32m$state\033[0m $name ($item), size: $size, url: \033[34m$url\033[0m"
  fi
  if [ "$state" = "pending" ] || [ "$state" = "working" ]; then
    loadedsize=$(cat upload-state.txt | jq -r ".[3] | .[$i].loaded_size")
    speed=$(cat upload-state.txt | jq -r ".[3] | .[$i].speed")
    started_time=$(cat upload-state.txt | jq -r ".[3] | .[$i].ctime")
    echo "\033[33m$state\033[0m, loaded size: $loadedsize, speed: $speed, running since: $started_time, url: \033[34m$url\033[0m"
  fi
  if [ "$state" = "failed" ] || [ "$state" = "retry" ]; then
    loadedsize=$(cat upload-state.txt | jq -r ".[3] | .[$i].loaded_size")
    last_error=$(cat upload-state.txt | jq -r ".[3] | .[$i].last_error")
    echo "\033[31m$state\033[0m, error: $last_error, loaded size: $loadedsize, url: \033[34m$url\033[0m"
  fi
  i=$(($i + 1))
  state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")
done

rm upload-state.txt
