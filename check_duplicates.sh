#!/bin/bash
set -xv
#---------------------------------------------------------------------------
#              Module name : 
#              Description : 
#
#                   Author : J. Cordisco
#             Date created : 08/09/2023
#-----
#            Modifications :
#                     Date :
#                   Author :
#                   Object :
#
#--------------------------------------------------------------------------------------

DIRECTORIES=("$CFTRECET" "$CFTENVOI" "$UNXTMP")
EMAIL="your_email@example.com"
FICLOG=$UNXLOG/"$(date +%d-%b-%Y)"-"$(date +%T)"-"$S_PROCEXE".log
SCRIPT="Check.sh"

if [ -n "$1" ]; then
	NUMBER_FILES=$1
else
	NUMBER_FILE=5
fi
	
declare -A file_count
declare -A file_paths


for DIRECTORY in "${DIRECTORIES[@]}"; do
    for file in "$DIRECTORY"/*; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            name="${filename%.*}"
			file_count["$name"]=$((file_count["$name"] + 1))
            file_paths["$name"]+="$filename\n"
        fi
    done
done


for name in "${!file_count[@]}"; do
    if [ ${file_count["$name"]} -gt $NUMBER_FILES ]; then
        echo "There are more than $NUMBER_FILES with the name: '$name' in '$CFTRECEPT'." >> ${FICLOG}
    fi
done


email_body=""
for key in "${!file_count[@]}"; do
    if [ ${file_count["$key"]} -gt $X ]; then
        email_body+="In the folder ${DIRECTORY} the following files were found:\n" >> ${FICLOG}
        email_body+="${file_paths["$key"]}\n" >> ${FICLOG}
    fi
done


if [ -n "$email_body" ]; then
	echo -e "$email_body" >> ${FICLOG}
    echo -e "$email_body" | mailx -s "File Extension Alert" $EMAIL 
fi


exit 0