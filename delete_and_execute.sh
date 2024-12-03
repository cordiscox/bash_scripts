#!/bin/bash
set -vx
#---------------------------------------------------------------------------
#-----                       -=- Script DELETE OF FILES AND CHAIN EXECUTION -=-
#---------------------------------------------------------------------------
#  Nom du module          : delete_and_execute.sh
#  Description du module  :
#       Numero de version : V1.0
#-----
#                  Auteur : Joaco
#           Date creation : 22/06/24
#-----
#           Modifications :
#                  Auteur :
#       Date mofification :
#                   Objet :
#
# Description du fonctionnement du module :
#
#       This script deletes the files in files_to_delete.cfg and then executes the strings in run_chains.cfg.
#
#--------------------------------------------------------------------------
 
script="delete_and_execute"
date="`date +%d/%m/%Y,%H%M`"
date_trait="`date +%m%d%H%M`"
heur_trait="`date +%H%M%S`"
ficlog=$HOME/joaco/${date_trait}${script}.log
 
to_delete=$HOME/joaco/files_to_delete.cfg
run_chains=$HOME/joaco/run_chains.cfg
 
# Verifica si los archivos existen
if [ ! -f "$to_delete" ]; then
    echo "The file $to_delete not exist." >>${ficlog}
    exit 1
fi
 
if [ ! -f "$run_chains" ]; then
    echo "The file $run_chains not exist." >>${ficlog}
    exit 1
fi
 
# Lee el archivo files_to_delete.cfg línea por línea y elimina los archivos listados
while IFS= read -r archivo; do
 
    for file in $UNXTMP/$archivo; do
        if [ -f "$file" ]; then
            echo "Deleting $file" >>${ficlog}
            rm "$file"
        else
            echo "The file $file not exist." >>${ficlog}
        fi
    done
 
    for file in $UNXRECEPT/$archivo; do
        if [ -f "$file" ]; then
            echo "Deleting $file" >>${ficlog}
            rm "$file"
        else
            echo "The file $file not exist." >>${ficlog}
        fi
    done
 
done <"$to_delete"
 
# Lee el archivo run_chains.cfg línea por línea y las va ejecutando una a una.
while IFS= read -r archivo; do
 
    for CHAIN in $archivo; do
        uxordre SES=${CHAIN} UPR=${CHAIN}U09 FORCE BYPASS MU=$(uxshw tsk ses="${CHAIN}" mu=* upr=* NOMODEL | awk 'NR==10 {print $4}')
        sleep 120
#        while [ "$(uxlst ctl ses=${CHAIN} | grep EXECUTION_EN_COURS | awk '{print $5}')" == "EXECUTION_EN_COURS" ]; do
#
#            echo "${CHAIN} Still running, Wait 60 seconds" >>${ficlog}
#            sleep 60
#
#        done
 
#        if [ "$(uxlst ctl upr=${CHAIN}U89 since=${date} | grep TERMINE | awk '{print $5}')" == "TERMINE" ]; then
#            echo "${CHAIN} finalize correctly" >>${ficlog}
#        else
#            echo "${CHAIN} finalize in abort" >>${ficlog}
#        fi
    done
 
done <"$run_chains"
 
# Save and cleanup
cd $HOME/joaco
 
cp files_to_delete.cfg histo/${date_trait}files_to_delete.cfg
cp1=$?
cp run_chains.cfg histo/${date_trait}run_chains.cfg
cp2=$?
 
ctrl=`expr $cp1 + $cp2`
if [ $ctrl -eq 0 ]; then
    echo "Le fichier a ete sauvegarde" >>${ficlog}
else
    echo "La sauvegarde du fichier a rencontre un probleme" >>${ficlog}
    exit 1
fi
 
>files_to_delete.cfg
>run_chains.cfg
