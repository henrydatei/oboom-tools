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

i=3

state=$(curl -s -d "token=$session" "https://api.oboom.com/1/remote/lsall" | jq -r ".[$i] | .[0].state")

while [ "$state" != "null" ]; do
  curl -s -d "token=$session" "https://api.oboom.com/1/remote/lsall" >> upload-state.txt
  state=$(cat upload-state.txt | jq -r ".[$i] | .[0].state")
  url=$(cat upload-state.txt | jq -r ".[$i] | .[0].url")
  if [ "$state" == "complete" ]; then
    name=$(cat upload-state.txt | jq -r ".[$i] | .[0].name")
    size=$(cat upload-state.txt | jq -r ".[$i] | .[0].size")
    item=$(cat upload-state.txt | jq -r ".[$i] | .[0].item")
    echo "\033[32m$state\033[0m $name ($item), size: $size, url: \033[34m$url\033[0m"
  else
    loadedsize=$(cat upload-state.txt | jq -r ".[$i] | .[0].loaded_size")
    speed=$(cat upload-state.txt | jq -r ".[$i] | .[0].speed")
    echo "\033[33m$state\033[0m, loaded size: $loadedsize, speed: $speed, url: \033[34m$url\033[0m"
  fi
  i=$(($i + 1))
  state=$(curl -s -d "token=$session" "https://api.oboom.com/1/remote/lsall" | jq -r ".[$i] | .[0].state")
done

if [ -f upload-state.txt ]; then
  rm upload-state.txt
else
  echo "No uploads found."
fi
