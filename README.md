zbackup
======

`Warning` Use this software at your own risk.

## Overview
zbackup is a shell script to backup your Website Files and MySQL Databases to Google Drive with [gdrive](https://github.com/prasmussen/gdrive/), a command line utility for interacting with Google Drive.

1. Creates a folder in Google Drive. Eg: `Website Backups - MyWebsiteName.com`
2. Exports MySQL Database with `mysqldump`
3. Creates tar archive of exported MySQL Database.
4. Creates tar archive of defined `public_html` path.
5. Uploads both archives to created Google Drive folder.
6. Removes old backups from local storage and Google Drive.

You'll need to download your required version of gdrive from the [gdrive project homepage](https://github.com/prasmussen/gdrive/).

## Installation
* Download the version of [gdrive](https://github.com/prasmussen/gdrive/) compatable with your server's operating system.
* Edit the scripts's config variables for your enviroment.
* Run `gdrive about` and copy/paste the link to your browser.
  * Copy/paste the generated code from your browser into the waiting input of the `gdrive about` command.
* Run `zbackup.sh` to start the backup.
* Schedule cron to run nightly, etc..


## Configuration
```
# Path to gdrive binary
gdrive_path="/home/username/zbackup/gdrive-linux-x64"

# Location to store backup archives
backup_path="/home/username/zbackup/backups"

# Path to website public_html or www folder
public_html="/home/username/public_html"

# Database Host, Port, User, Password
database_host="localhost"
database_port="3306"
database_user="root"
database_pass="securepassword"

# Database to backup. Use --all-databases to backup all databases.
database_name="--all-databases"

# Name of folder in Google Drive to create and place backup files.
backup_folder="Website Backups - MyWebsiteName.com"

# Number of backups to keep
number_backup_keep=7
```
