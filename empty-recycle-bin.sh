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
#declare -a recyclebin
parent=$(cat tree.json | jq ".[1] | .[$i].parent")
while [ "$parent" != "null" ]; do
  parent=$(cat tree.json | jq -r ".[1] | .[$i].parent")
  type=$(cat tree.json | jq -r ".[1] | .[$i].type")
  if [ "$parent" == "1C" ]; then
    name=$(cat tree.json | jq -r ".[1] | .[$i].name")
    id=$(cat tree.json | jq -r ".[1] | .[$i].id")
    echo "Found file in recycle bin: \033[32m$name\033[0m ($id)"
  fi
  if [ $(($i % 100)) -eq 0 ]; then
    #only show status every 100 files
    echo "Found \033[32m$i\033[0m files."
  fi
  i=$(echo "$i + 1" | bc)
done
rm tree.json
