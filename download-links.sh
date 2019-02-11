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

if [ -f files.txt ] && [ -f folders.txt ]; then
  echo "Do you want to download files (f) or a complete folder (d)?"
  read type
  if [ "$type" = "f" ]; then
    # download files
    NumberOfFiles=$(cat files.txt | wc -l | bc)
    echo "\033[32m$NumberOfFiles\033[0m folder(s) available. Please type the name of the file."
    read search
    cat files.txt | grep "$search" > searchresult.txt
    NumberOfSearchResults=$(cat searchresult.txt | wc -l | bc)
    echo "Found \033[32m$NumberOfSearchResults\033[0m file(s):"
    while read -r line; do
      name=$(echo "$line" | cut -d "|" -f1)
      id=$(echo "$line" | cut -d "|" -f6)
      echo "  $name ($id)"
    done < searchresult.txt
    echo "Do you want to create download links? They will be saved in \033[32mdownload-links.txt\033[0m. (Y/n)"
    read createLinks
    if [ "$createLinks" = "n" ]; then
      exit
    else
      while read -r line; do
        filename=$(echo "$line" | cut -d "|" -f1)
        fileid=$(echo "$line" | cut -d "|" -f6)
        result=$(curl -s "https://api.oboom.com/1/dl?token=$session&item=$fileid")
        errorid=$(echo "$result" | jq -r '.[0]')
        if [ "$errorid" -eq 200 ]; then
          # everything ok
          dlDomain=$(echo "$result" | jq -r '.[1]')
          dlToken=$(echo "$result" | jq -r '.[2]')
          echo "https://$dlDomain/dlh?ticket=$dlToken" >> download-links.txt
        else
          # maybe some problems
          if [ "$errorid" -eq 503 ]; then
            # serivce currently not available. trying again
            result=$(curl -s "https://api.oboom.com/1/dl?token=$session&item=$fileid")
            errorid=$(echo "$result" | jq -r '.[0]')
            if [ "$errorid" -eq 200 ]; then
              # retry successful
              dlDomain=$(echo "$result" | jq -r '.[1]')
              dlToken=$(echo "$result" | jq -r '.[2]')
              echo "https://$dlDomain/dlh?ticket=$dlToken" >> download-links.txt
            else
              echo "Problems! Error code: $errorid for file $filename"
              echo "$result"
            fi
          else
            # real problems
            echo "Problems! Error code: $errorid for file $filename"
            echo "$result"
          fi
        fi
      done < searchresult.txt
    fi
  fi
  if [ "$type" = "d" ]; then
    # download folder
    NumberOfFolders=$(cat folders.txt | wc -l | bc)
    echo "\033[32m$NumberOfFolders\033[0m folder(s) available. Please type the name of the folder."
    read search
    cat folders.txt | grep "$search" > searchresult.txt
    NumberOfSearchResults=$(cat searchresult.txt | wc -l | bc)
    echo "Found \033[32m$NumberOfSearchResults\033[0m folder(s):"
    while read -r line; do
      name=$(echo "$line" | cut -d "|" -f1)
      id=$(echo "$line" | cut -d "|" -f6)
      ContainingFiles=$(cat files.txt | grep "$id" | wc -l | bc)
      echo "  Name: $name ($id), containing file(s): $ContainingFiles"
    done < searchresult.txt
    echo "Do you want to create download links? They will be saved in \033[32mdownload-links.txt\033[0m. (Y/n)"
    read createLinks
    if [ "$createLinks" = "n" ]; then
      exit
    else
      while read -r line; do
        name=$(echo "$line" | cut -d "|" -f1)
        id=$(echo "$line" | cut -d "|" -f6)
        echo "Proceeding search result $name."
        cat files.txt | grep "$id" > temp.txt
        echo "### Download links for $name" >> download-links.txt
        while read -r details; do
          # for every search result proceed all files
          fileid=$(echo "$details" | cut -d "|" -f6)
          filename=$(echo "$details" | cut -d "|" -f1)
          result=$(curl -s "https://api.oboom.com/1/dl?token=$session&item=$fileid")
          errorid=$(echo "$result" | jq -r '.[0]')
          if [ "$errorid" -eq 200 ]; then
            # everything ok
            dlDomain=$(echo "$result" | jq -r '.[1]')
            dlToken=$(echo "$result" | jq -r '.[2]')
            echo "https://$dlDomain/dlh?ticket=$dlToken" >> download-links.txt
          else
            # maybe some problems
            if [ "$errorid" -eq 503 ]; then
              # serivce currently not available. trying again
              result=$(curl -s "https://api.oboom.com/1/dl?token=$session&item=$fileid")
              errorid=$(echo "$result" | jq -r '.[0]')
              if [ "$errorid" -eq 200 ]; then
                # retry successful
                dlDomain=$(echo "$result" | jq -r '.[1]')
                dlToken=$(echo "$result" | jq -r '.[2]')
                echo "https://$dlDomain/dlh?ticket=$dlToken" >> download-links.txt
              else
                echo "Problems! Error code: $errorid for file $filename"
                echo "$result"
              fi
            else
              # real problems
              echo "Problems! Error code: $errorid for file $filename"
              echo "$result"
            fi
          fi
        done < temp.txt
      done < searchresult.txt
    fi
  fi
  if [ "$type" != "d" ] && [ "$type" != "f" ]; then
    # unknown option
    echo "Unknown option $type."
    exit
  fi
else
  echo "Files \033[32mfiles.txt\033[0m and/or \033[32mfolders.txt\033[0m not found. Please run \033[32mlist-all-files.sh\033[0m to create them."
fi

rm searchresult.txt
if [ -f temp.txt ]; then
  rm temp.txt
fi
