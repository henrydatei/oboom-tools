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
name=$(curl -s "https://api.oboom.com/1/ls?token=$session&item=$folderid" | jq -r '.[1].name')

# calc size
sum=0
touch $folderid.txt

curl -s "https://api.oboom.com/1/ls?token=$session&item=$folderid" | jq '.[2] | .[].size' >> $folderid.txt
while read line; do
  sum=$(echo "$sum + $line" | bc)
done < $folderid.txt
kilobytes=$(echo "scale=2; $sum / 1024" | bc)
megabytes=$(echo "scale=2; $sum / 1048576" | bc)
gigabytes=$(echo "scale=2; $sum / 1073741824" | bc)

echo "The folder \033[32m$folderid\033[0m (\033[32m$name\033[0m) is \033[32m$sum\033[0m bytes big. That are \033[32m$kilobytes\033[0m KB or \033[32m$megabytes\033[0m MB or \033[32m$gigabytes\033[0m GB."

rm $folderid.txt
