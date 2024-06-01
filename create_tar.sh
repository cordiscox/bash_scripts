#!/bin/sh
set -vx
#---------------------------------------------------------------------------
# 	Module Name			: create_tar.sh
#   Module DeSCRIPTion  : SCRIPT to tar files contained in a directory with nomenclature prd+fp+IDFILE+d
#
#							ex: SESSION: S4J06 --> s4jfp06d
#							ex: SESSION: ERIX04 --> erifpX04d
#							ex: SESSION: PL5ABC --> pl5fpABCd
#
#
#---------------------------------------------------------------------------

PRDSPECIF=$(echo ${S_PROCEXE} | cut -c 1-3)
prdspecif=$(echo ${PRDSPECIF} | tr "[:upper:]" "[:lower:]")
fichier=$(echo ${S_CODSESS} | cut -c 4-)
FICLOG=$UNXLOG/"$(date +%d-%b-%Y)"-"$(date +%T)"-"${S_PROCEXE}".log
SCRIPT="create_tar.sh"
FOLDER_NAME=${prdspecif}"fp"${fichier}"d"
TAR_NAME=${nomfic}

#-----
#----- Start of the create_tar.sh job
#-----
echo "${S_PROCEXE}: Starting ${SCRIPT} on $(date +%d-%b-%Y) at $(date +%T)" >> ${FICLOG}

verif_folder=$(ls -ltr $UNXENVOI/. | grep ${FOLDER_NAME} | wc -l)
if [ $verif_folder -eq 0 ]; then
    echo "The directory ${FOLDER_NAME} does not exist" >> ${FICLOG}
    exit 1
else
    echo "The directory ${FOLDER_NAME} exists" >> ${FICLOG}
    verif_fic=$(ls $UNXENVOI/${FOLDER_NAME}/. | wc -l)
    if [ $verif_fic -ne 0 ]; then
        echo "The directory ${FOLDER_NAME} is not empty" >> ${FICLOG}
        cd $UNXENVOI/${FOLDER_NAME}
        tar -vcf $TAR_NAME *
        if [ $? -ne 0 ]; then
            echo "The .tar could not be created" >> ${FICLOG}
        else
            chmod 777 $TAR_NAME
            mv $TAR_NAME $UNXTMP
            echo "The .tar has been created and placed in the tmp directory" >> ${FICLOG}
            rm *
        fi
    else
        echo "The directory ${FOLDER_NAME} is empty" >> ${FICLOG}
    fi
fi
 
exit 0