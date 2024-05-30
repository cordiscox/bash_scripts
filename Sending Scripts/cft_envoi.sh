#!/bin/sh
set -vx
#---------------------------------------------------------------------------
#-----                         -=- Sending script -=-
#---------------------------------------------------------------------------
#  Module name             : cft_envoi.sh
#  Module description      : Common sending script for host interface
#                            Extraction is done based on the file name(s) extracted from $U
#                            and declared in the outbound IDF configuration ($UNXEXDATA/"prd"fcid1.cfg)
#                            it is necessary to fill in this latter file to link
#                            between file, idf, partner
#       Version number     : V1.0
#-----
#
# Module operation description :
#
# - verification of IDF existence
# - saving the file in UNXSAVDAT and UNXSAVDAT/N_tmp
# - file sending
# - purging the file in UNXTMP as soon as CFT takes it (absent in UNXENVOI)
#
#--------------------------------------------------------------------------
PRDSPECIF=`echo $S_PROCEXE | cut -c 1-3`
prdspecif=`echo ${PRDSPECIF} | tr "[:upper:]" "[:lower:]"`
FICHIER=`echo $S_CODSESS | cut -c 4-`
ficlog=$UNXLOG/"`date +%d-%b-%Y`"-"`date +%T`"-"$S_PROCEXE".log
date_trait="`date +%d-%b-%Y`"
heur_trait="`date +%T`"
script="cft_envoi.sh"
 
# SFR definition of the .cfg perl file
ficidf=$UNXEXDATA/"$prdspecif"fcid1.cfg
 
ficctl=$UNXTMP/"$UNXPRDAPPLI"fpZ5s2.dat
UNXPRDAPPLI=`echo ${UNXPRDAPPLI} | tr "[:lower:]" "[:upper:]"`

#-----
#----- Start of the job cft_envoi.sh
echo "${S_PROCEXE}:Starting ${script} on `date +%d-%b-%Y` at `date +%T` " >> ${ficlog}

# Verification of file definitions present in the CFT config
for fictest in `ls $UNXTMP/ | grep ${prdspecif}fi${FICHIER}`; do
    if [ `grep $fictest $ficidf | wc -l` -eq 0 ]; then
        echo "${S_PROCEXE}:The file $fictest cannot be sent as it is not defined in CFT">> ${ficlog}
        #echo "$S_CODSESS : $S_PROCEXE cannot send the file ${UNXTMP}/${fictest} as it is not defined in CFT" | mailx -s "CFT Alert: Undefined File" example@gmail.com
        exit 1
    fi
done

#-----
grep "${prdspecif}fi${FICHIER}" $ficidf | awk '{print $1}' > $UNXTMP/lstFic_$$.tmp
 
# The '$UNXTMP/lstFic_$$.tmp' file is purged after 5 days using the script (PRD_0pu.sh)
if [ ! -s $UNXTMP/lstFic_$$.tmp ]; then
    echo "The file ${prdspecif}fi${FICHIER} is not defined in CFT" >> ${ficlog}
    echo "or there was a problem with the command 'grep "${prdspecif}fi${FICHIER}" $ficidf | awk '{print \$1}' > $UNXTMP/lstFic_$$.tmp'" >> ${ficlog}
    exit 1
fi
 
for fichier in `cat $UNXTMP/lstFic_$$.tmp`; do
    if [ `echo "${fichier}" | wc -w` -eq 0 ]; then
        exit 1
    else
        if [ -f "$UNXTMP/${fichier}" ]; then
            # SFR - Retrieving fields in the .cfg perl file
            fic=`grep $fichier $ficidf`
            idf=`echo ${fic} | awk '{print $2}'`
            part=`echo ${fic} | awk '{print $3}'`
            nbenr=`wc -l "$UNXTMP/${fichier}" | awk '{print $1}'`
            echo "${S_PROCEXE}:The file ${fichier} exists, it contains $nbenr records " >> ${ficlog}
            ret=`$UNXEXSCRIPT/generique/RETENTION_FICHIER ${S_CODSESS}`
            cd $UNXTMP
            nom_fic_sauve="${date_trait}"-"${heur_trait}"-`echo ${fichier}`.sav
            cp -pr "${fichier}" "$UNXSAVDAT/${nom_fic_sauve}"
            cp1=$?
            cp -pr "${fichier}" "$UNXSAVE/${ret}tmp/${nom_fic_sauve}"
            cp2=$?
            mv "$UNXSAVE/${ret}tmp/${nom_fic_sauve}" "$UNXSAVE/${ret}/${nom_fic_sauve}"
            mv1=$?
            ctrl=`expr $cp1 + $cp2 + $mv1`
            if [ $ctrl -eq 0 ]; then
                echo "${S_PROCEXE}:The file ${fichier} has been saved" >> ${ficlog}
            else
                echo "${S_PROCEXE}:There was a problem with saving the file ${fichier}" >> ${ficlog}
                exit 1
            fi
            cp $UNXTMP/${fichier} $UNXENVOI/${fichier}
            if [ $? -eq 0 ]; then
                echo "${S_PROCEXE}:Starting CFT sending of file ${fichier} at `date +%T`" >> ${ficlog}
                $CFTEXSCRIPT/cft_0md.pl $UNXENVOI/${fichier} ${idf} ${part}
                while [ -f $UNXENVOI/${fichier} ]; do
                    sleep 10
                done
                rm $UNXTMP/${fichier}
                echo "${S_PROCEXE}:The file ${fichier} containing $nbenr records has been successfully sent on `date +%Y-%m-%d` at `date +%T` " >> ${ficlog}
            else
				echo "${S_PROCEXE}:Problem copying file to UNXENVOI" >> ${ficlog}
				exit 1
            fi
        else
            echo "${S_PROCEXE}:The file ${fichier} does not exist in UNXTMP" >> ${ficlog}
        fi
    fi
done

if [ $? -ne 0 ]; then
    echo "Problem with the command 'cat $UNXTMP/lstFic_$$.tmp'" >> ${ficlog}
    exit 1
else
    rm $UNXTMP/lstFic_$$.tmp
fi

echo "${S_PROCEXE}:End of ${script} on `date +%d-%b-%Y` at `date +%T` " >> ${ficlog}

exit 0

