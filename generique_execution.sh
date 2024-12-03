#!/bin/bash
set -vx
#---------------------------------------------------------------------------
#-----                       -=- Script Execute Sessions -=-
#---------------------------------------------------------------------------
#   Nom du module           : To_define
#   Description du module   :
#   Numero de version       : V1.0
#-----
#                  Auteur   : Joaco
#           Date creation   : 03/11/24
#-----
#
#   Description du fonctionnement du module :
#       PARAMETERS: $1 FILE NAME TO INTEGRATE
#       To define.
#
#--------------------------------------------------------------------------
PRDSPECIF=`echo $S_PROCEXE | cut -c 1-3`
prdspecif=`echo ${PRDSPECIF} | tr "[:upper:]" "[:lower:]"`
script="To define"
date="`date +%d/%m/%Y,%H%M`"
date_trait="`date +%m%d%H%M`"
heur_trait="`date +%H%M%S`"
ficlog=$UNXLOG/${date_trait}${script}.log

file=$1

cfgfile=$UNXEXDATA/"$prdspecif"fcid2.cfg
# Check

echo "Starting ${script} on ${date}" >> ${ficlog}


if [ `grep $checkfile $cfgfile | wc -l` -eq 0 ]; then
	echo "The file${file} cannot be processed because it's not defined in ${cfgfile}">> ${logfile}
	exit 1
fi

if ! ls "$CFTRECEPT/${file}"* >/dev/null 2>&1; then
    echo "The file ${file} doesn't exist in ${CFTRECEPT}" >> "${ficlog}"
    exit 2
fi

cfg=`grep ${file} $cfgfile`
idf=`echo ${cfg} | awk '{print $2}'`
mode=`echo ${cfg} | awk '{print $3}'`

if [ "${mode}" -eq "F" ]; then
    for file in `ls "$CFTRECEPT/${file}"*`; do
        uxordre SES=${S_CODSESS} UPR=${S_CODSESS}U09 FORCE BYPASS MU=$(uxshw tsk ses="${S_CODSESS}" mu=* upr=* NOMODEL | awk 'NR==10 {print $4}')
        while [ "$(uxlst ctl ses=ERATEST since=(${date}) | grep EXECUTION_EN_COURS | awk '{print $5}')" -eq "EXECUTION_EN_COURS" ]; do
            echo "${S_CODSESS} Still running, Wait 60 seconds" >>${ficlog}
            sleep 60
        done
    done
else [ "${mode}" -eq "A" ]; then
    uxordre SES=${S_CODSESS} UPR=${S_CODSESS}U09 FORCE BYPASS MU=$(uxshw tsk ses="${S_CODSESS}" mu=* upr=* NOMODEL | awk 'NR==10 {print $4}')
fi


# uxlst ctl ses=ERATEST since=(${date}) | grep EXECUTION_EN_COURS | awk '{print $5}'

#uxlst ctl ses=ERATEST since=("`date +%m%d%H%M`",0000)