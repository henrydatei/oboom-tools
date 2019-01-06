# oboom-tools

Bundle of shell scripts to manage your OBOOM-account via the OBOOM-api. See [https://www.oboom.com/api/](https://www.oboom.com/api/)

### login.sh
This script gives you a session-key (or token) generated from your account credentials. The session-key is required for all other api requests. The script uses your e-mail adress and a pbkdf2 hash of your password. Currently I'm not able to implement pbkdf2 in shell. To get the pbkdf2 hash of your password please an other program. I use [http://anandam.name/pbkdf2/](http://anandam.name/pbkdf2/) with 1000 iterations and 16 bytes for the key. The salt is your reversed password.

Your username and the password hash is saved in a file named `account.txt`. The session-id is saved with a timestamp in `session.txt`. Other scripts use this to get the session-id automatically. Please note that your session-id is only 30 minutes valid. After that you have to run `login.sh` again to get a new session-id

### remote-upload.sh
With this script you can remote-upload files to oboom. It's very useful if you have a rapitgator- (or other file hoster-) link that you want to download. "Upload" this link to oboom and oboom will download the file. After that you can download your files from oboom.

### remote-upload-list.sh
Does basically the same as `remote-upload.sh` but remote-uploads a complete list of links.

### last-uploads.sh
Displays details about your last uploads.

### mkdir.sh
Creates a new directory.

### security-pin.sh
Looks if you have a security pin set. If not, oboom will send you one via e-mail. You need a security pin for removing files from the recycle bin.

### empty-recycle-bin.sh
Deletes all files and folders from the recycle bin. You'll need your security pin.

### ideas for new scripts
- [x] empty recycle bin
- [ ] restart failed remote uploads
