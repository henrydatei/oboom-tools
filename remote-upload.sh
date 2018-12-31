echo "This script wants a link of a file hoster (rapitgator, filer, ...) that will be remote uploaded to oboom"
echo "It creates a new folder on oboom where you will be able to find your file"
read -p "session id: " session
read -p "name of the folder (please no spaces): " folder
read -p "link of the file: " link

echo "Creating folder \033[32m$folder\033[0m."
folderid=$(curl -s "https://api.oboom.com/1/mkdir?token=$session&parent=1&name=$folder" | jq -r '.[1]')
echo "Created folder \033[32m$folder\033[0m with id \033[32m$folderid\033[0m."
curl -s -d "token=$session" -d "remotes=[{\"url\":\"$link\",\"parent\":\"$folderid\"}]" "https://api.oboom.com/1/remote/add" >> /dev/null
echo "Upload successful."
