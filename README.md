# oboom-tools

Bundle of shell scripts to manage your OBOOM-account via the OBOOM-api. See [https://www.oboom.com/api/](https://www.oboom.com/api/). All scripts are written in **shell, not in bash**! You can start then via `sh script.sh` or `./script.sh` (maybe you have to make them executable with `chmod +x script.sh`).

For the documentation please visit the wiki!

### remote-upload.sh
With this script you can remote-upload files to oboom. It's very useful if you have a rapitgator- (or other file hoster-) link that you want to download. "Upload" this link to oboom and oboom will download the file. After that you can download your files from oboom.

**It seems to be that oboom has currently some problems with the remote-upload. I'm not sure when they will fix it.**

### remote-upload-list.sh
Does basically the same as `remote-upload.sh` but remote-uploads a complete list of links.

**It seems to be that oboom has currently some problems with the remote-upload. I'm not sure when they will fix it.**

### last-uploads.sh
Displays details about your last uploads.

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

### download-links.txt
After running `list-all-files.sh` this script searches for an entered keyword in `files.txt` or `folders.txt`. After that it will create download links (for all found results) which you can put into JDownloader or anything else.

### ideas for new scripts
- [x] empty recycle bin
- [x] restart failed remote uploads
- [x] download files
