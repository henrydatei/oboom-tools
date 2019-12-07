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

folderid=$1
# get name of folder
name=$(curl -s "https://api.oboom.com/1/ls?token=$session&item=$folderid" | jq '.[1].name')

calcFolderSize() {
  totalbytes=0
  touch $1.txt

  curl -s "https://api.oboom.com/1/ls?token=$session&item=$1" | jq '.[2] | .[].size' >> $1.txt
  while read line; do
    totalbytes=$(echo "$totalbytes + $line" | bc)
  done < $1.txt

  echo "$totalbytes"
  rm $1.txt
}

calcFolderSize2() {
  sum=0
  touch Type-$1.txt
  touch ID-$1.txt

  curl -s "https://api.oboom.com/1/ls?token=$session&item=$1" | jq -r '.[2] | .[].type' >> Type-$1.txt
  curl -s "https://api.oboom.com/1/ls?token=$session&item=$1" | jq -r '.[2] | .[].id' >> ID-$1.txt

  if [ -z $(cat Type-$1.txt | grep "folder") ]; then
    # no folder in current directory -> use calcFolderSize()
    size=$(calcFolderSize $1)
    sum=$(echo "$sum + $size" | bc)
  else
    # at least one folder in current directory
    while read line; do
      i=1
      type=$(cat Type-$1.txt | head -n $i | tail -n 1)
      if [ "$type" = "file" ]; then
        # current line is a file
        size=$(curl -s "https://api.oboom.com/1/info?token=$session&items=$line" | jq '.[1] | .[].size')
        sum=$(echo "$sum + $size" | bc)
      else
        # current line is a folder
        size=$(calcFolderSize2 $line)
        sum=$(echo "$sum + $size" | bc)
      fi
      i=$(echo "$i + 1" | bc)
    done < ID-$1.txt
  fi

  rm Type-$1.txt
  rm ID-$1.txt

  echo "$sum"
}

size=$(calcFolderSize2 $folderid)
kilobytes=$(echo "scale=2; $size / 1024" | bc)
megabytes=$(echo "scale=2; $size / 1048576" | bc)
gigabytes=$(echo "scale=2; $size / 1073741824" | bc)
echo "The folder \033[32m$folderid\033[0m (\033[32m$name\033[0m) is \033[32m$size\033[0m bytes big. That are \033[32m$kilobytes\033[0m KB or \033[32m$megabytes\033[0m MB or \033[32m$gigabytes\033[0m GB."
