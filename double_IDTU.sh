#!/bin/ksh

#Solve problem of overwriting of files
#Files arrives with format NAME.???.????? so we need transform to NAME.???

set -xv
cd $CFTRECEPT

filename="$1"
files=($(ls -ltr ${filename}* | awk '{print $9}' | tr '\n' ' '))

if [ "${files[0]}" == "" ]; then
        echo "No files for ${filename} in $(pwd)"
        exit 0
fi

count=1

for file in ${filename}.*.*; do
    # Extract base file name
    base_name="${file%.*.*}"

        #Delete FLAG file.
        rm ${base_name}.*.flag

    # Create new file name
    new_name="${base_name}.$(printf "%03d" $count)"

    if [ -f $new_name ]; then
        echo "The file ${new_name} already exist in CFTRECEPT, you need to rename or move it to continue with this script"
        exit 1
    fi

    # rename
    mv "$file" "$new_name"

    # Increment
    count=$((count+1))
done
