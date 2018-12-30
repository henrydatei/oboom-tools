echo "This script wants a list of links of file hosters (rapitgator, filer, ...) that will be remote uploaded to oboom"
echo "It creates a new folder on oboom where you will be able to find your files"
read -p "session id: " session
read -p "name of the folder (please no spaces): " folder
read -p "list of files: " file

if [ -n -f $file ]; then
  echo "File \033[32m$file\033[0m does not exists."
else
  echo "Creating folder \033[32m$folder\033[0m."
  folderid=$(curl -s "https://api.oboom.com/1/mkdir?token=$session&parent=1&name=$folder" | jq -r '.[1]')
  echo "Created folder \033[32m$folder\033[0m with id \033[32m$folderid\033[0m."
fi
