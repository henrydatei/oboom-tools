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

result=$(curl -s "https://api.oboom.com/1/du?token=$session")
totalNUM=$(echo "$result" | jq '.[1] | .total.num')
totalSIZE=$(echo "$result" | jq '.[1] | .total.size')
rootNUM=$(echo "$result" | jq '.[1] | ."1".num')
rootSIZE=$(echo "$result" | jq '.[1] | ."1".size')
binNUM=$(echo "$result" | jq '.[1] | ."1C".num')
binSIZE=$(echo "$result" | jq '.[1] | ."1C".size')

echo "\033[32mroot\033[0m:        $rootNUM files, $rootSIZE bytes"
echo "\033[32mrecycle bin\033[0m: $binNUM files, $binSIZE bytes"
echo "\033[32mtotal\033[0m:       $totalNUM files, $totalSIZE bytes"
