# Linux System Administration & Bash Scripting Challenges

---

## 📄 Overview & Purpose

> ### **Lab Purpose**
> **Core Objective:** A collection of hands-on Linux system administration tasks and Bash scripting exercises demonstrating user account lifecycle automation, local directory backups, log file cleanup auditing, and file system inspection.

---

## 🛠️ Scripting Challenges & Solutions

### Challenge 1: Bulk User Account Provisioning

#### **Task Description**
Create a script that accepts a file path containing a list of usernames as an argument. The script verifies that the executing user has root or `sudo`/`wheel` privileges, reads the input file line-by-line, and provisions Linux user accounts with `/bin/bash` shells and default home directories.

```bash
#!/bin/bash
echo "Hello, $1!"

# Verify root or sudo/wheel group privileges
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

# Process file and create user accounts
while read -r username _; do
  userid=$(id -u$username 2>/dev/null)

  if [[ $userid -ge 0 ]]; then
    sudo useradd -m -s /bin/bash "$username"
    echo $userid
  fi

done < $FILE_PATH

## 🛠️ Scripting Challenges & Solutions

### Challenge 2: Bulk User Account Deprovisioning

#### **Task Description**
#### Create a script to clean up user accounts from an input file. The script verifies permissions and checks each account's UID before deletion to ensure only standard, non-system user accounts (UID $\ge$ 1001) are removed along with their home directories (userdel -r).

```bash
#!/bin/bash
echo "Hello, $1!"

# Verify root or sudo/wheel group privileges
if [[ $EUID -ne 0 ]]; then
  if groups | grep -qE '\b(sudo|wheel)\b'; then
    echo "In sudo or wheel"
  else 
    echo "Not enough permissions to create/delete users"
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

# Process file and remove standard users
while read -r username _; do
  userid=$(id -u$username 2>/dev/null)

  if [[ $userid -ge 1001 ]]; then
    sudo userdel -r "$username"
    echo $userid
  fi

done < $FILE_PATH


## 🛠️ Scripting Challenges & Solutions

### Challenge 3: Automated Directory Archiving & Backup

#### **Task Description**
#### Develop a backup utility that takes a source directory path as an argument (defaulting to $HOME/foldertobackup if unsupplied). The script validates path existence, ensures a destination $HOME/backups directory exists, and creates a timestamped .tar archive of the target folder.

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

if [[ -d "$HOME/backups" ]]; then
  echo "Exists"
else
  mkdir "$HOME/backups"
  echo "$HOME/backups: created"
fi

DATETIME="backup_"$(date +%Y-%m-%d_%H%M)

tar -cvf $HOME/backups/$DATETIME.tar $FILE_PATH


## 🛠️ Scripting Challenges & Solutions

### Challenge 4: Active Log Search & Cleanup Reporting

#### **Task Description**
#### Write a script that scans a designated search path (defaulting to $HOME/foldertosearch), strips trailing slashes if present, and searches for non-empty .log files modified within the last 7 days (-mtime -7). The results and metadata are saved to a report file named cleanup_report.txt.

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

for file in $(find$SEARCHPATH \( -name "*.log" -size +1c \) -mtime -7); do

  if [ ! -f "$SEARCHPATH""/cleanup_report.txt" ]; then
    touch "$SEARCHPATH""/cleanup_report.txt"
  fi

  echo $(ls -la $file) >> "$SEARCHPATH""/cleanup_report.txt"
done


## 🛠️ Scripting Challenges & Solutions

### Challenge 5: File & Directory Property Inspector

#### **Task Description**
#### Create a system inspector script that evaluates a target argument. If the target is a single file, it outputs read/write/execute permissions and converts its size to KB. If the target is a directory, it iterates through all contained items and outputs formatted permissions, item size in KB, basename, and full path.


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

  echo $R $W$X

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
    
    [[ -r "$item" ]] && R="Readable" || R="Not Readable"
    [[ -w "$item" ]] && W="Writable" || W="Not Writable"
    [[ -x "$item" ]] && X="Executable" || X="Not Executable"

    echo $R $W$X

    echo "$size KB	$name$item"
  done
fi