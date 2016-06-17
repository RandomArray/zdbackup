#!/bin/sh

## Backup of website database and files uploaded to Google Drive with gdrive
## Get gdrive (Google Drive CLI Client) from github.com/prasmussen/gdrive


# Path to gdrive Binary
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

# Number of backups to
number_backup_keep=7

####



startBackup () {
  
  google_folder_id=$1
  mysql_backup_filename="$backup_path/mysql_`date +%Y-%m-%d`"
  files_backup_filename="$backup_path/files_`date +%Y-%m-%d`"
  
  ## Dump MySQL Database(s)
  
  echo "Exporting Database..."
  mysqldump --opt --quick --hex-blob --max_allowed_packet=500M --add-drop-table=true --complete-insert=true --compress --lock-tables=false --host="$database_host" --port="$database_port" --user="$database_user" --password="$database_pass" $database_name > $mysql_backup_filename.sql
  
  echo "Archiving Database..."
  tar -czpf $mysql_backup_filename.tar.gz -C / $mysql_backup_filename.sql 2>/dev/null
  
  ## Archive Site Files
  echo "Archiving Site Files..."
  tar -czpf $files_backup_filename.tar.gz -C / $public_html --exclude-vcs 2>/dev/null
  
  ## Remove SQL Dump if file exists
  if [ -f $mysql_backup_filename.sql ] ; then
      echo "Cleanup Database Export..."
      rm $mysql_backup_filename.sql
  fi

  echo "Uploading MySQL Archive: $mysql_backup_filename.tar.gz"
  $gdrive_path upload --parent $google_folder_id $mysql_backup_filename.tar.gz
  
  echo "Uploading Site Files Archive: $files_backup_filename.tar.gz"
  $gdrive_path upload --parent $google_folder_id $files_backup_filename.tar.gz
  
  ## Clean Up Old Backups
  backup_number_keep=$((number_backup_keep+1))
  old_mysql_archive=($(ls -1 $backup_path/mysql_* | sort -r | tail -n +$backup_number_keep | xargs echo))
  old_files_archive=($(ls -1 $backup_path/files_* | sort -r | tail -n +$backup_number_keep | xargs echo))
  
  ## Remove old backups from Google Drive
  echo "Clean-Up Old MySQL Archive..."
  for filepath in "${old_mysql_archive[@]}"
  do
    filename=$(basename $filepath)
  	fileData=$($gdrive_path list -q "mimeType = 'application/x-gzip' AND name='$filename' AND trashed=false" --no-header)
  	file_data=($fileData)
  	fileID=${file_data[0]}
  
  if [[ -n "${fileID// }" ]]
      then
          echo "Removing Old MySQL Archive from Google Drive: $filename"
       	  $gdrive_path delete $fileID
  fi
  
  	echo "Removing Old Archive: $filename"
  	rm $filepath
  done

  ############ REMOVE OLD SITE FILES ARCHIVE
  
  echo "Clean-Up Old Site Files Archive..."
  for filepath in "${old_files_archive[@]}"
  do
    filename=$(basename $filepath)
  	fileData=$($gdrive_path list -q "mimeType = 'application/x-gzip' AND name='$filename' AND trashed=false" --no-header)
  	file_data=($fileData)
  	fileID=${file_data[0]}
  
  if [[ -n "${fileID// }" ]]
      then
          echo "Removing Old Site File Archive from Google Drive: $filename"
       	  $gdrive_path delete $fileID
  fi
  
   	echo "Removing Old Archive: $filename"
   	rm $filepath
   	
  done
  
  
}



## Find Folder ID if exists
folderData=$($gdrive_path list -q "mimeType = 'application/vnd.google-apps.folder' AND name='$backup_folder' AND trashed=false" --no-header)

## If folder does not exist create new folder.
if [[ -z "${folderData// }" ]]
then
    echo 'Creating Folder: $backup_folder'
    new_folder=$($gdrive_path mkdir "$backup_folder")
    # echo "NewFolder: $new_folder"
    new_folder=($new_folder)
    folderID=${new_folder[1]}
else
    folder_data=($folderData)
    folderID=${folder_data[0]}
fi


if [[ -n "${folderID// }" ]]
then
    #execute if the the variable is not empty and contains non space characters
    echo "FOLDER EXISTS - ID: $folderID"
    startBackup $folderID
else
    #execute if the variable is empty or contains only spaces
    echo "ERROR CREATING FOLDER"
    startBackup $folderID
fi
