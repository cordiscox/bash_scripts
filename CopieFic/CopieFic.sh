#!/bin/ksh
set -vx
#---------------------------------------------------------------------------
#              Module name : CopieFic.sh
#              Description : The CopieFic.sh script copies the files defined in $UNXEXDATA/CopieFic.cfg
#                              according to the session name.
#
#                              The $UNXEXDATA/CopieFic.cfg file must be populated with:
#							   1: Session Name
#							   2: Absolute path of the file to be copied
#							   3: Absolute path of the destination file
#							   4: OPTIONAL Unix command (cp or mv) if you don't denifine this, for default is cp
#
#                            ex: SIKA5 /users/sik00/tmp/sikfwA5tmp.dat /users/sik00/data/sikfwA5tmp2.dat cp
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
# $S_PROCEXE and $S_CODSESS are enviroments variables from Dollar Universe
PRDSPECIF=$(echo $S_PROCEXE | cut -c 1-3)
prdspecif=$(echo ${PRDSPECIF} | tr "[:upper:]" "[:lower:]")
fichier=$(echo $S_CODSESS | cut -c 4-)
ficlog=$UNXLOG/"$(date +%d-%b-%Y)"-"$(date +%T)"-"$S_PROCEXE".log
script="CopieFic.sh"
copcfg=$UNXEXDATA/CopieFic.cfg
work=/tmp/work${$}.txt
#-----
#----- Start of the CopieFic.sh job
#-----
echo "${S_PROCEXE}: Starting ${script} on $(date +%d-%b-%Y) at $(date +%T)" >> ${ficlog}
#-----
#----- Test for the presence of the script configuration file
#-----
if [ ! -s $copcfg ]; then
    echo "${S_PROCEXE}: The file $copcfg is empty or does not exist" >> ${ficlog}
    exit 1
fi
#----- Test for the presence of a file definition to copy for this session
if [ $(grep $S_CODSESS $copcfg | wc -l) -eq 0 ]; then
    echo "${S_PROCEXE}: No file is defined for this session" >> ${ficlog}
    exit 1
fi
#-----  Copy the files defined in $UNXDATA/CopieFic.cfg
grep ${S_CODSESS} $copcfg | awk '{print $2" "$3" "$4}' > $work
while read nom_fic_source nom_fic_destination command_unix; do
    if [ -f $nom_fic_source ]; then
        if [ ${command_unix} ]; then
            ${command_unix} $nom_fic_source $nom_fic_destination
        else
            cp -pr $nom_fic_source $nom_fic_destination
        fi
        if [ $? -eq 0 ]; then
            echo "${S_PROCEXE}: The file $nom_fic_source has been copied to $nom_fic_destination" >> ${ficlog}
        else
            echo "${S_PROCEXE}: Copy of $nom_fic_source failed" >> ${ficlog}
            exit 1
        fi
    else
        echo "${S_PROCEXE}: The file $nom_fic_source does not exist" >> ${ficlog}
    fi
done < $work
rm $work
echo "${S_PROCEXE}: End of ${script} on $(date +%d-%b-%Y) at $(date +%T)" >> ${ficlog}
