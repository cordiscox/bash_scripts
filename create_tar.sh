#!/bin/sh
set -vx
#---------------------------------------------------------------------------
# 	Module Name			: create_tar.sh
#   Module Description  : Script to tar files contained in a directory with nomenclature prd+fp+IDFILE+d
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
date_trait="$(date +%d-%b-%Y)"
heur_trait="$(date +%T)"
ficlog=$UNXLOG/"${date_trait}"-"${heur_trait}"-"${S_PROCEXE}".log
script="create_tar.sh"
coderetour=0
name_folder=${prdspecif}"fp"${fichier}"d"
name_tar=${nomfic}

#-----
#----- Start of the create_tar.sh job
#-----
echo "${S_PROCEXE}: Starting ${script} on $(date +%d-%b-%Y) at $(date +%T)" >> ${ficlog}

verif_folder=$(ls -ltr $UNXENVOI/. | grep ${name_folder} | wc -l)
if [ $verif_folder -eq 0 ]; then
    echo "The directory ${name_folder} does not exist" >> ${ficlog}
    exit 1
else
    echo "The directory ${name_folder} exists" >> ${ficlog}
    verif_fic=$(ls $UNXENVOI/${name_folder}/. | wc -l)
    if [ $verif_fic -ne 0 ]; then
        echo "The directory ${name_folder} is not empty" >> ${ficlog}
        cd $UNXENVOI/${name_folder}
        tar -vcf $name_tar *
        if [ $? -ne 0 ]; then
            echo "The .tar could not be created" >> ${ficlog}
        else
            chmod 777 $name_tar
            mv $name_tar $UNXTMP
            echo "The .tar has been created and placed in the tmp directory" >> ${ficlog}
            rm *
        fi
    else
        echo "The directory ${name_folder} is empty" >> ${ficlog}
    fi
fi
 
exit 0
