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

#try to avoid data loss because of overwriting the files
if [ -f folders.txt ]; then
  echo "Found a file with name \033[32mfolders.txt\033[0m. To run this program this file needs to be \033[31mdeleted\033[0m. Do you want to delete it? (y/N)"
  read answer
  if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    echo "Removing file \033[31mfolders.txt\033[0m"
    rm folders.txt
  else
    exit
  fi
fi
if [ -f files.txt ]; then
  echo "Found a file with name \033[32mfiles.txt\033[0m. To run this program this file needs to be \033[31mdeleted\033[0m. Do you want to delete it? (y/N)"
  read answer
  if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    echo "Removing file \033[31mfiles.txt\033[0m"
    rm files.txt
  else
    exit
  fi
fi

echo "Downloading file information ... "
curl -s -d "token=$session" "https://api.oboom.com/1/tree" > tree.json
echo "Reprocessing your files ... (This could take up to some minutes, depending on how many files you have)"
i=0
entry=$(cat tree.json | jq ".[1] | .[$i]")
while [ "$entry" != "null" ]; do
  type=$(cat tree.json | jq -r ".[1] | .[$i].type")
  if [ "$type" = "folder" ]; then
    #entry in tree.json is a folder
    name=$(cat tree.json | jq -r ".[1] | .[$i].name")
    root=$(cat tree.json | jq -r ".[1] | .[$i].root")
    state=$(cat tree.json | jq -r ".[1] | .[$i].state")
    user=$(cat tree.json | jq -r ".[1] | .[$i].user")
    ddl=$(cat tree.json | jq -r ".[1] | .[$i].ddl")
    id=$(cat tree.json | jq -r ".[1] | .[$i].id")
    ctime=$(cat tree.json | jq -r ".[1] | .[$i].ctime")
    parent=$(cat tree.json | jq -r ".[1] | .[$i].parent")
    downloads=$(cat tree.json | jq -r ".[1] | .[$i].downloads")
    mtime=$(cat tree.json | jq -r ".[1] | .[$i].mtime")
    atime=$(cat tree.json | jq -r ".[1] | .[$i].atime")
    echo "$name|$root|$state|$user|$ddl|$id|$ctime|$parent|$downloads|$mtime|$atime" >> folders.txt
  else
    #entry in tree.json is a file
    name=$(cat tree.json | jq -r ".[1] | .[$i].name")
    root=$(cat tree.json | jq -r ".[1] | .[$i].root")
    state=$(cat tree.json | jq -r ".[1] | .[$i].state")
    user=$(cat tree.json | jq -r ".[1] | .[$i].user")
    ddl=$(cat tree.json | jq -r ".[1] | .[$i].ddl")
    id=$(cat tree.json | jq -r ".[1] | .[$i].id")
    ctime=$(cat tree.json | jq -r ".[1] | .[$i].ctime")
    parent=$(cat tree.json | jq -r ".[1] | .[$i].parent")
    downloads=$(cat tree.json | jq -r ".[1] | .[$i].downloads")
    mtime=$(cat tree.json | jq -r ".[1] | .[$i].mtime")
    atime=$(cat tree.json | jq -r ".[1] | .[$i].atime")
    size=$(cat tree.json | jq -r ".[1] | .[$i].size")
    thumb_320=$(cat tree.json | jq -r ".[1] | .[$i].thumb_320")
    mime=$(cat tree.json | jq -r ".[1] | .[$i].mime")
    owner=$(cat tree.json | jq -r ".[1] | .[$i].owner")
    echo "$name|$root|$state|$user|$ddl|$id|$ctime|$parent|$downloads|$mtime|$atime|$size|$thumb_320|$mime|$owner" >> files.txt
  fi
  i=$(echo "$i + 1" | bc)
  entry=$(cat tree.json | jq ".[1] | .[$i]")
done
echo "You can find your list of folders in \033[32mfolders.txt\033[0m."
echo "You can find your list of files in \033[32mfiles.txt\033[0m."
rm tree.json
