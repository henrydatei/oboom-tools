# oboom-tools

Bundle of shell scripts to manage your OBOOM-account via the OBOOM-api. See [https://www.oboom.com/api/](https://www.oboom.com/api/). All scripts are written in **shell, not in bash**! You can start then via `sh script.sh` or `./script.sh` (maybe you have to make them executable with `chmod +x script.sh`).

For the documentation please visit the wiki!

## Prerequisites

These scripts use the following packages, so please ensure that you've installed them
- jq
- bc
- curl

### mkdir.sh
Creates a new directory in root.

### security-pin.sh
Looks if you have a security pin set. If not, oboom will send you one via e-mail. You need a security pin for removing files from the recycle bin.

### empty-recycle-bin.sh
Deletes all files and folders from the recycle bin. You'll need your security pin.

### restart-uploads.sh
Scans for failed remote-uploads, removes them from the queue and adds them to the queue again.

### list-all-files.sh
Running through your files and folders and getting information about them. Output are two files: `folders.txt` and `files.txt` that are containing the following information delimited by "|" for each file/folder in one line:
- **information about folders:**
  - name
  - root
  - state
  - user
  - ddl
  - id
  - ctime
  - parent
  - downloads
  - mtime
  - atime
- **information about files:**
  - name
  - root
  - state
  - user
  - ddl
  - id
  - ctime
  - parent
  - downloads
  - mtime
  - atime
  - size
  - thumb_320
  - mime
  - owner

### download-links.sh
After running `list-all-files.sh` this script searches for an entered keyword in `files.txt` or `folders.txt`. After that it will create download links (for all found results) which you can put into JDownloader or anything else.

### get-remote-upload-links.sh
Prints out all the links which were in the remote upload queue.

### abort-failed-uploads.sh
Aborts all failed remote uploads.

### disk-usage.sh
Displays information about the amount of files and the used space in your OBOOM-account. `-1` means that you have so many files/bytes used that OBOOM doesn't want to calculate that.

### get-folder-size.sh <folderID>
This will display the size of the folder, calculated as the sum of the sizes of all files in it. The script will need an input parameter, the folderID, which can be accessed by right-clicking in the webGUI on a folder an clicking "export links". The 8-digit mixture of letters and numbers after "folder/" is the folderID.
