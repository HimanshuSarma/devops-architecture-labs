#!/bin/bash
echo "Hello, $1!"

SEARCHPATH="$1"

if [[ -z $1 ]]; then
  echo "No argument provided"
  SEARCHPATH="$HOME/foldertosearch"
fi


last_char="${SEARCHPATH: -1}"

if [ $last_char == '/' ]; then
  SEARCHPATH="${SEARCHPATH%?}"
fi


for file in $(find $SEARCHPATH \( -name "*.log" -size +1c  \) -mtime -7); do

  if [ ! -f "$SEARCHPATH""/cleanup_report.txt" ]; then
    touch "$SEARCHPATH""/cleanup_report.txt"
  fi

  echo $(ls -la $file) >> "$SEARCHPATH""/cleanup_report.txt"
done