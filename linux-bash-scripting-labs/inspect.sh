#!/bin/bash
echo "Hello, $1!"

if [[ ! -f "$1" && ! -d "$1" ]]; then
  echo "$1 doesn't exist"
  exit 1
fi

if [[ -f $1 ]]; then
  [[ -r "$1" ]] && R="Readable" || R="Not Readable"
  [[ -w "$1" ]] && W="Writable" || W="Not Writable"
  [[ -x "$1" ]] && X="Executable" || X="Not Executable"

  echo $R $W $X

  SIZE_IN_BYTES=$(ls -la $1 | awk '{print $5 / 1024}')
  echo $SIZE_IN_BYTES KB

elif [[ -d $1 ]]; then
  echo "Target: $1 (Directory)"
  echo "--- Contents ---"

  # Loop over all files/directories within the target directory
  for item in "$1"/*; do
    # Get the name of the item only (basename)
    name=$(basename "$item")
    
    # Get the size in KB
    size=$(ls -ld "$item" | awk '{printf "%.2f", $5 / 1024}')
    
    [[ -r "$1" ]] && R="Readable" || R="Not Readable"
    [[ -w "$1" ]] && W="Writable" || W="Not Writable"
    [[ -x "$1" ]] && X="Executable" || X="Not Executable"

    echo $R $W $X

    echo "$size KB	$name $item"
  done
fi