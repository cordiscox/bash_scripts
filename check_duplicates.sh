#!/bin/bash
#set -xv
#---------------------------------------------------------------------------
#              Module name : check_duplicate
#              Description : This script checks specific directories and counts how many files with the same name (but different extensions) exist.
#                            If any file appears more than a specified number of times (default is 5), 
#                            it generates a report and sends an alert via email.
#
#                   Author : J. Cordisco
#             Date created : 08/09/2023
#-----
#            Parameters    : #1 --> Number of files - OPTIONAL
#                            ex: check_duplicates 3
#            Modifications :
#                     Date :
#                   Author :
#                   Object :
#
#--------------------------------------------------------------------------------------
#-- SET-UP ENVOIREMENT VARIABLES MANUALLY TO TEST
#UNXLOG=/workspaces/bash_scripts
#CFTRECET=/workspaces/bash_scripts/testFolder
#CFTENVOI=/workspaces/bash_scripts/lalaFolder
#-----------------------------
DIRECTORIES=("$CFTRECET" "$CFTENVOI")
EMAIL="joaquin@gmail.com"
FICLOG=$UNXLOG/"$(date +%d-%b-%Y)"-"$(date +%T)"-"$$".log
SCRIPT="check_duplicate.sh"

if [ -n "$1" ]; then
    NUMBER_FILES=$1
else
    NUMBER_FILES=5
fi
    
email_body=""
for DIRECTORY in "${DIRECTORIES[@]}"; do
    declare -A file_count

    for file in "$DIRECTORY"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            name="${filename%.*}"
            file_count["$name"]=$((file_count["$name"] + 1))
        fi
    done

    for name in "${!file_count[@]}"; do
        if [ ${file_count["$name"]} -gt $NUMBER_FILES ]; then
            if [[ "$email_body" != *"$DIRECTORY"* ]]; then
                email_body+="In the folder ${DIRECTORY} found:\n"
            fi
            email_body+="file: $name was found ${file_count["$name"]} times\n"
        fi
    done

    unset file_count
done

if [ -n "$email_body" ]; then
    echo -e "$email_body" >> ${FICLOG}
    echo -e "$email_body" | mailx -s "Files Alert" $EMAIL 
fi

exit 0
