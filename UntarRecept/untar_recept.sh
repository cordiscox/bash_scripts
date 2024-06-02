#!/bin/sh
#set -vx
#---------------------------------------------------------------------------
#-----                     -=- Uncompress SCRIPT -=-
#---------------------------------------------------------------------------
#             Module name  : untar_recept.sh
#                Function  : Default SCRIPT to uncompress an incoming file <tar_file>
#                           to a destination_path_folder,validating that the file and the destination_path_folder 
#                           exist before the action.
#--------------------------------------------------------------------------
#Gzip
#tar -xzvf archivo.tar.gz
#------------
#Bzip2
#tar -xjvf archivo.tar.bz2
#------------
#Xz
#tar -xJvf archivo.tar.xz

readonly DATE_TRAIT=$(date +"%d-%b-%Y")
readonly TIME_TRAIT=$(date +"%T")
readonly SCRIPT="untar_file.sh"
readonly LOGFILE="${CODESPACE_VSCODE_FOLDER}/${DATE_TRAIT}-${TIME_TRAIT}-${SCRIPT}.log"

tar_file=$1
if [ -z "$tar_file" ]; then
    echo "Parameter tar_filename was not provided when you call the script ${SCRIPT}" >>  ${LOGFILE}
    exit 1
fi

path_configfile="${CODESPACE_VSCODE_FOLDER}/untar_file.cfg"
config=$(grep ${tar_file} ${path_configfile})

if [ -z "$config" ]; then
    echo "The configuration for file ${tar_file} was not found in ${path_configfile}" >>  ${LOGFILE}
    exit 1
fi

tar_filename=$(echo "$config" | awk '{print $1}')
origin_path_file=$(echo "$config" | awk '{print $2}')
destination_path_folder=$(echo "$config" | awk '{print $3}')

# Beginning of the SCRIPT untar_recept.sh
echo "Starting ${SCRIPT} on ${DATE_TRAIT} at ${TIME_TRAIT}" >> ${LOGFILE}
 
# Check for the tar file existence
if [ -d ${destination_path_folder} ]; then

    if [ -f ${origin_path_file}/${tar_filename} ]; then
        # Move the tar from the $origin_path_file to the specified destination_path_folder

        #SOME BACKUP ??? ADD HERE
        mv ${origin_path_file}/${tar_filename} ${destination_path_folder}/
        mv=$?
        chmod 777 ${destination_path_folder}/${tar_filename}
        ch=$?
        co_mvch=`expr $mv + $ch`

        if [ $co_mvch -eq 0 ];then
			echo "File ${tar_filename} moved to destination ${destination_path_folder}" >> ${LOGFILE}
        else
			echo "${tar_filename} encountered a problem to mv or chmod" >> ${LOGFILE}
			exit 1
        fi
        
        case "$tar_filename" in
        *.tar.gz)
            if tar -xzvf "${destination_path_folder}/${tar_filename}" -C "${destination_path_folder}"; then
                echo "The .tar.gz was decompressed in ${destination_path_folder}" >> "${LOGFILE}"
            else
                echo "Error decompressing the .tar.gz file" >> "${LOGFILE}"
                exit 1
            fi
            ;;
        *.tar.bz2)
            if tar -xjvf "${destination_path_folder}/${tar_filename}" -C "${destination_path_folder}"; then
                echo "The .tar.bz2 was decompressed in ${destination_path_folder}" >> "${LOGFILE}"
            else
                echo "Error decompressing the .tar.bz2 file" >> "${LOGFILE}"
                exit 1
            fi
            ;;
        *.tar.xz)
            if tar -xJvf "${destination_path_folder}/${tar_filename}" -C "${destination_path_folder}"; then
                echo "The .tar.xz was decompressed in ${destination_path_folder}" >> "${LOGFILE}"
            else
                echo "Error decompressing the .tar.xz file" >> "${LOGFILE}"
                exit 1
            fi
            ;;
        *.tar)
            if tar -xvf ${destination_path_folder}/${tar_filename} -C ${destination_path_folder}; then
                echo "The .tar was decompressed in ${destination_path_folder}" >> ${LOGFILE}
            else
                echo "Error decompressing the tar file" >> ${LOGFILE}
                exit 1
            fi
            ;;
        *)
            echo "file with unknow extension" >> "${LOGFILE}"
            exit 1
            ;;
        esac
        
        rm -f "${destination_path_folder}/${tar_filename}"
        echo "File ${tar_filename} deleted on ${DATE_TRAIT} at ${TIME_TRAIT}" >> "${LOGFILE}"
        ls -lrth ${destination_path_folder} >> "${LOGFILE}"
        echo "Script ${SCRIPT} finished well" >> ${LOGFILE}
    else
        echo "File does not exist" >> ${LOGFILE}
    fi
else
    echo "Directory does not exist" >> ${LOGFILE}
fi

exit 0