if [ -f account.txt ]; then
  echo "Login information found in \033[32maccount.txt\033[0m."
  username=$(cat account.txt | cut -d "|" -f1)
  passwordhash=$(cat account.txt | cut -d "|" -f2)
else
  echo "No login information found. Creating file \033[32maccount.txt\033[0m."
  echo "You can calculate your password hash on http://anandam.name/pbkdf2/. The salt is the reversed password."
  read -p "Username: " username
  read -p "PBKDF2 Password-Hash: " passwordhash
  echo "$username|$passwordhash" >> account.txt
fi

session=$(curl -s "https://www.oboom.com/1/login?auth=$username&pass=$passwordhash&source=1" | jq -r '.[1].session')
timestamp=$(date +%s)
echo "$timestamp|$session" >> session.txt
echo "Created file \033[32msession.txt\033[0m to save your session-id. Other script can now automatically login."
echo "Your session-id is \033[32m$session\033[0m."
