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

partcounter=1
linecounter=1
folderid=$1
numberofparts=$2

curl -s -d "token=$session" "https://api.oboom.com/1/ls?item=$folderid" | jq -r '.[2] | .[] | .name' | sort > names_raw.txt

# remove duplicate line
echo "\033[32mDuplicate parts\033[0m"
cat names_raw.txt | uniq -d | rev | cut -d "." -f2 | rev
cat names_raw.txt | uniq > names.txt

checkLineForNumber() {
  linenumber=$1
  number=$2

  partblock=$(cat names.txt | head -n $linenumber | tail -n 1 | rev | cut -d "." -f2 | rev)
  result=$(echo "$partblock" | grep "$number")
  if [ -z $result ]; then
    #not found
    echo "fail"
  else
    echo "success"
  fi
}

echo "\033[31mMissing parts\033[0m"
while read line; do
  result=$(checkLineForNumber $linecounter $partcounter)
  while [ "$result" = "fail" ] && [ $partcounter -le $numberofparts ]; do
    echo "part $partcounter is missing"
    partcounter=$(echo "$partcounter + 1" | bc)
    result=$(checkLineForNumber $linecounter $partcounter)
  done
  linecounter=$(echo "$linecounter + 1" | bc)
  partcounter=$(echo "$partcounter + 1" | bc)
done < names.txt

rm names.txt
rm names_raw.txt
