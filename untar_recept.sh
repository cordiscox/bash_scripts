#!/bin/sh
set -vx
#---------------------------------------------------------------------------
#-----                     -=- Uncompress Script -=-
#---------------------------------------------------------------------------
#             Module name  : untar_recept.sh
#                Function  : Default script to uncompress an incoming file <tar_file>
#                           to a folder specified in the uproc <tar_folder>,
#                           validating that the file and the folder exist before
#                           the action.
#--------------------------------------------------------------------------
# Variables
PRDSPECIF=$(echo ${S_PROCEXE:0:3})
prdspecif=$(echo ${PRDSPECIF} | tr "[:upper:]" "[:lower:]")
date_trait=$(date +"%d-%b-%Y")
time_trait=$(date +"%T")
script="untar_recept.sh"
logfile="${UNXLOG}/${date_trait}-${time_trait}-${S_PROCEXE}.log"
file_name="${tar_file}"
folder="${tar_folder}"
 
# Beginning of the script untar_recept.sh
echo "${S_PROCEXE}: Starting ${script} on ${date_trait} at ${time_trait}" >> ${logfile}
 
# Check for the tar file existence
if [ -d ${UNXTMP}${folder} ]; then
    # Give access rights to the target folder before decompressing
    chmod 777 ${UNXTMP}${folder}
    if [ -f ${UNXTMP}/${file_name} ]; then
        # Move the tar from the $UNXTMP to the specified folder
        mv ${UNXTMP}/${file_name} ${UNXTMP}${folder}/${file_name}
        chmod 777 ${UNXTMP}${folder}/${file_name}
        echo "${S_PROCEXE}: File ${file_name} moved to folder ${UNXTMP}${folder}" >> ${logfile}
 
        # Decompress the tar in the destination folder
        if tar -xvf ${UNXTMP}${folder}/${file_name} -C ${UNXTMP}${folder}; then
            echo "${S_PROCEXE}: The .tar was decompressed in ${UNXTMP}${folder}" >> ${logfile}
            rm -f ${UNXTMP}${folder}/${file_name}
            echo "${S_PROCEXE}: File ${file_name} deleted on ${date_trait} at ${time_trait}" >> ${logfile}
        else
            echo "${S_PROCEXE}: Error decompressing the tar file" >> ${logfile}
            exit 1
        fi
 
        ls -lrth ${UNXTMP}${folder}
    else
        echo "${S_PROCEXE}: File does not exist" >> ${logfile}
    fi
else
    echo "${S_PROCEXE}: Directory does not exist" >> ${logfile}
fi
