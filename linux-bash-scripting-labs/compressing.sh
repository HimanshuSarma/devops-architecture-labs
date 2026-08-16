#!/bin/bash
echo "Hello, $1!"

FILE_PATH=$1

if [[ -z $1 ]]; then
  echo "No argument provided"
  FILE_PATH="$HOME/foldertobackup"
fi

echo $FILE_PATH

if [[ ! -f "$FILE_PATH" && ! -d "$FILE_PATH" ]]; then
  echo "$FILE_PATH doesn't exist"
  exit 1
fi

if [[  -d "$HOME/backups" ]]; then
  echo "Exists"
else
  mkdir "$HOME/backups"
  echo "$HOME/backups: created"
fi

DATETIME="backup_"$(date +%Y-%m-%d_%H%M)

tar -cvf $HOME/backups/$DATETIME.tar $FILE_PATH