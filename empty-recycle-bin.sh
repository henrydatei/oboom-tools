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

echo "Indexing files ... (This could take up to some minutes, depending on how many files you have)"
curl -s -d "token=$session" "https://api.oboom.com/1/tree" >> tree.json
i=2
root=$(cat tree.json | jq ".[1] | .[$i].root")
while [ "$root" != "null" ]; do
  root=$(cat tree.json | jq -r ".[1] | .[$i].root")
  type=$(cat tree.json | jq -r ".[1] | .[$i].type")
  if [ "$root" = "1C" ] && [ "$type" = "file" ]; then
    name=$(cat tree.json | jq -r ".[1] | .[$i].name")
    id=$(cat tree.json | jq -r ".[1] | .[$i].id")
    parent=$(cat tree.json | jq -r ".[1] | .[$i].parent")
    echo "Found file in recycle bin: \033[34m$name\033[0m ($id)"
    if [ "$parent" = "1C" ]; then
      # files that are not in a folder will be added to the deleting-queue
      echo "$name|$id" >> recycle-bin.txt
    fi
  fi
  if [ "$root" = "1C" ] && [ "$type" = "folder" ]; then
    name=$(cat tree.json | jq -r ".[1] | .[$i].name")
    id=$(cat tree.json | jq -r ".[1] | .[$i].id")
    echo "Found folder in recycle bin: \033[33m$name\033[0m ($id)"
    # add folders to queue for recursive deleting
    echo "$name|$id" >> recycle-bin.txt
  fi
  if [ $(($i % 100)) -eq 0 ]; then
    #only show status every 100 files
    echo "Found \033[32m$i\033[0m files."
  fi
  i=$(echo "$i + 1" | bc)
done
rm tree.json

if [ -f recycle-bin.txt ]; then
  echo "Do you really want to delete this files and folders (and it's containing files) forever? (y/n)"
  while read line; do
    name=$(echo "$line" | cut -d '|' -f1)
    id=$(echo "$line" | cut -d '|' -f2)
    echo "  \033[31m$name\033[0m ($id)"
  done < recycle-bin.txt
  read remove_confirmation
  if [ "$remove_confirmation" = "y" ]; then
    echo "Files/folders will be removed. You'll need your security pin. If you don't have anyone, please run \033[32msecurity-pin.sh\033[0m"
    read -p "your security pin: " pin
    result=$(curl -s "https://www.oboom.com/1/pincode/check?token=$session&pin=$pin")
    errorcode=$(echo "$result" | jq -r '.[0]')
    security_token=$(echo "$result" | jq -r '.[1]')
    if [ $errorcode -eq 200 ]; then
      echo "Your first security one-time-token is \033[32m$security_token\033[0m."
      echo "Removing files/folders ..."
      while read line; do
        name=$(echo "$line" | cut -d '|' -f1)
        id=$(echo "$line" | cut -d '|' -f2)
        echo "Deleting \033[31m$name\033[0m."
        # need a new security token for every deletion
        security_token=$(curl -s "https://www.oboom.com/1/pincode/check?token=$session&pin=$pin" | jq -r '.[1]')
        curl -s "https://api.oboom.com/1/rm?token=$session&items=$id&secure_token=$security_token&recursive=true&move_to_trash=false" >> /dev/null
      done < recycle-bin.txt
      echo "Everything in the recycle-bin deleted."
    else
      echo "There are problems. Errorcode \033[31m$errorcode\033[0m, Message: \033[31m$security_token\033[0m."
    fi
  else
    echo "Ok, no file will be removed."
  fi
  rm recycle-bin.txt
else
  echo "No files in recycle bin."
fi
