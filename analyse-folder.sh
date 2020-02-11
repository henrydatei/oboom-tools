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

curl -s -d "token=$session" "https://api.oboom.com/1/ls?item=$folderid" | jq -r '.[2] | .[] | select(.name | contains("part"))' > raw.txt
cat raw.txt | jq -r '.name' | sort > names_raw.txt

# remove duplicate line
echo "\033[32mDuplicate parts\033[0m"
cat names_raw.txt | uniq -d | rev | cut -d "." -f2 | rev
cat names_raw.txt | uniq -d | rev | cut -d "." -f2 | rev > duplicates.txt
cat names_raw.txt | uniq > names.txt
while read line; do
  number=$(echo $line | cut -c 5-)
  id=$(cat raw.txt | jq -r "select(.name | contains(\"part$number\")) | .id" | tail -n 1)
  echo "removing part$number with id $id ..."
  curl -s -d "token=$session" "https://api.oboom.com/1/rm?items=$id" > /dev/null
done < duplicates.txt

if [ -z "$2" ]; then
  curl -s -d "token=$session" "https://api.oboom.com/1/ls?item=$folderid" | jq -r '.[2] | .[] | select(.name | contains("part"))' > raw.txt
  echo "Looking for smallest file in \033[32m$folderid\033[0m"
  SizeSmallestFile=$(cat raw.txt | jq -s 'sort_by(.size) | .[0].size')
  SizeSecondSmallestFile=$(cat raw.txt | jq -s 'sort_by(.size) | .[1].size')
  if [ $SizeSmallestFile -lt $SizeSecondSmallestFile ]; then
    # we've found a smallest file
    numberofparts=$(cat raw.txt | jq -s -r 'sort_by(.size) | .[0].name' | rev | cut -d "." -f2 | rev | cut -c 5- | bc)
    echo "Found \033[32m$numberofparts\033[0m parts"
  else
    # no smallest files
    echo "\033[31mCould not find a smallest file. Please give this script in the second argument the number of parts that should be in this folder\033[0m"
  fi
fi

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

rm duplicates.txt
rm raw.txt
rm names.txt
rm names_raw.txt
