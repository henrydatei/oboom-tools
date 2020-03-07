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

if [ "$1" = "force" ]; then
  while [ "$state" != "null" ]; do
    state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")
    if [ "$state" = "failed" ] || [ "$state" = "retry" ] || [ "$state" = "pending" ]; then
      url=$(cat upload-state.txt | jq -r ".[3] | .[$i].url")
      id=$(cat upload-state.txt | jq -r ".[3] | .[$i].id")
      parent=$(cat upload-state.txt | jq -r ".[3] | .[$i].parent")
      echo "Restarting url: \033[34m$url\033[0m, id: $id, parent: $parent"
      curl -s "https://api.oboom.com/1/remote/rm?token=$session&remotes=$id" >> /dev/null
      curl -s -d "token=$session" -d "remotes=[{\"url\":\"$url\",\"parent\":\"$parent\"}]" "https://api.oboom.com/1/remote/add" >> /dev/null
    fi
    i=$(($i + 1))
    state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")
  done
else
  while [ "$state" != "null" ]; do
    state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")
    if [ "$state" = "failed" ] || [ "$state" = "retry" ]; then
      url=$(cat upload-state.txt | jq -r ".[3] | .[$i].url")
      id=$(cat upload-state.txt | jq -r ".[3] | .[$i].id")
      parent=$(cat upload-state.txt | jq -r ".[3] | .[$i].parent")
      echo "Restarting url: \033[34m$url\033[0m, id: $id, parent: $parent"
      curl -s "https://api.oboom.com/1/remote/rm?token=$session&remotes=$id" >> /dev/null
      curl -s -d "token=$session" -d "remotes=[{\"url\":\"$url\",\"parent\":\"$parent\"}]" "https://api.oboom.com/1/remote/add" >> /dev/null
    fi
    i=$(($i + 1))
    state=$(cat upload-state.txt | jq -r ".[3] | .[$i].state")
  done
fi

rm upload-state.txt
