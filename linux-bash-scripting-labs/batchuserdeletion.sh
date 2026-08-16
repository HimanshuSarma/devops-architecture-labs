#!/bin/bash
echo "Hello, $1!"

if [[ $EUID -ne 0 ]]; then
  if groups | grep -qE '\b(sudo|wheel)\b'; then
    echo "In sudo or wheel"
  else 
    echo "Not enough permissions to create users"
    exit 1
  fi
fi

FILE_PATH=$1

if [[ -z $1 ]]; then
  echo "No argument provided"
  exit 1
fi

echo $FILE_PATH

echo 

# Recommended: Reliable and memory-efficient
while read -r username _; do
  # your code here
  userid=$(id -u $username)

  if [[ $userid -ge 1001 ]]; then
    sudo userdel -r "$username"
    echo $userid
  fi

done < $FILE_PATH
