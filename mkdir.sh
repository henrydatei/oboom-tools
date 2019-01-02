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

read -p "name of the folder (please no spaces): " folder

echo "Creating folder \033[32m$folder\033[0m."
folderid=$(curl -s "https://api.oboom.com/1/mkdir?token=$session&parent=1&name=$folder" | jq -r '.[1]')
echo "Created folder \033[32m$folder\033[0m with id \033[32m$folderid\033[0m."
