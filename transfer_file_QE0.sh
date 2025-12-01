#!/bin/bash

set -xv

folder="/users/cft00/recept"
fichier="cftrenvoi.tar.gz"
idf="ERA00011"
partner="L0015457"
date_trait=$( date +"%d-%b-%Y" )
heur_trait=$( date +"%T" )

cd $folder

if ls -A "$folder" | grep -q .; then
    echo "The $folder have files."
    tar czvf $fichier *
    tar=$?

    nom_fic_sauve="${date_trait}"-"${heur_trait}"-`echo ${fichier}`.sav
    cp -pr "${fichier}" "$UNXSAVDAT/${nom_fic_sauve}"
    chmod 666 $UNXSAVDAT/${nom_fic_sauve}
    cp=$?

    ctrl=`expr $cp + $tar`
    if [ $ctrl -eq 0 ];then
        echo "${S_PROCEXE}:Le fichier ${fichier} a ete compressed and sauvegarde"
    else
        echo "${S_PROCEXE}:La sauvegarde du fichier ${fichier} a rencontre un probleme"
        exit 1
    fi

    $CFTEXSCRIPT/cft_0md.pl $fichier $idf $partner

    rm $folder/*
else
    echo "The $folder is empty."
fi

exit 0
