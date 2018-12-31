# oboom-tools

Bundle of shell scripts to manage your OBOOM-account via the OBOOM-api. See [https://www.oboom.com/api/1/authentification](https://www.oboom.com/api/1/authentification)

### login.sh
This script gives you a session-key (or token) generated from your account credentials. The session-key is required for all other api requests. The script uses your e-mail adress and a pbkdf2 hash of your password. Currently I'm not able to implement pbkdf2 in shell. To get the pbkdf2 hash of your password please an other program. I use [http://anandam.name/pbkdf2/](http://anandam.name/pbkdf2/) with 1000 iterations and 16 bytes for the key. The salt is your reversed password.

Your username and the password hash is saved in a file named `account.txt`.

### remote-upload.sh
With this script you can remote-upload files to oboom. It's very useful if you have a rapitgator- (or other file hoster-) link that you want to download. "Upload" this link to oboom and oboom will download the file. After that you can download your files from oboom.

### last-uploads.sh
Displays details about your last uploads.
