#!/bin/ksh
set -vx

#Envoi with GPG

PRDSPECIF=`echo $S_PROCEXE | cut -c 1-3`
ses=`echo $S_PROCEXE | cut -c 1-5`
ficlog=$UNXLOG/"`date +%d-%b-%Y`"-"`date +%T`"-"$S_PROCEXE".log
date_trait="`date +%d-%b-%Y`"
heur_trait="`date +%T`"
script="eenvoi_perl.sh"

#SFR d▒finition du fichier .cfg perl
ficidf=$UNXEXDATA/galicia_client_send.cfg

ficctl=$UNXTMP/"$UNXPRDAPPLI"fpZ5s2.dat
UNXPRDAPPLI=`echo ${UNXPRDAPPLI} | tr "[:lower:]" "[:upper:]"`
nocp=0
#-----
#----- Debut du job eenvoi.sh
echo "${S_PROCEXE}:Demarrage du ${script} le `date +%d-%b-%Y` a `date +%T` " >> ${ficlog}
#-----
grep ${ses} $ficidf | while IFS= read -r session;
do
  fichier=`echo ${session} | awk '{print $1}'`
  if [ `echo "${fichier}" | wc -w` -eq 0 ]
    then
      exit 1
    else
      if [ -f "$UNXTMP/${fichier}" ]
        then
        idf=`echo ${session} | awk '{print $2}'`
        part=`echo ${session} | awk '{print $3}'`
        parm=`echo ${session} | awk '{print $4}'`
        conv=`echo ${session} | awk '{print $5}'`
		key=`echo ${session} | awk '{print $6}'`
          nbenr=`wc -l $UNXTMP/"${fichier}" | awk '{print $1}'`
          echo "${S_PROCEXE}:Le fichier ${fichier} existe , il contient $nbenr enregistrements " >> ${ficlog}
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
          if [ $ctrl -eq 0 ];then
          echo "${S_PROCEXE}:Le fichier ${fichier} a ete sauvegarde" >> ${ficlog}
          else
          echo "${S_PROCEXE}:La sauvegarde du fichier ${fichier} a rencontre un probleme" >> ${ficlog}
          exit 1
          fi
          /users/evb00/exploit/bin/gpg/gpg --trust-model always --encrypt --recipient ${key} $UNXTMP/${fichier}
          cp $UNXTMP/${fichier}.gpg $UNXENVOI/${fichier}.gpg
          if [ $? -eq 0 ]
            then
              echo "${S_PROCEXE}:Debut de l'envoie CFT du fichier ${fichier} a `date +%T`">> ${ficlog}
               $CFTEXSCRIPT/cft_0md.pl -options="parm=${parm}${conv}-`date +%Y%m%d`-`date +%H%M`" -send $UNXENVOI/${fichier}.gpg ${idf} ${part}
              while [ -f $UNXENVOI/${fichier}.gpg ]
              do
                sleep 10
              done
			        rm $UNXTMP/${fichier}
              rm $UNXTMP/${fichier}.gpg
                    echo "${S_PROCEXE}:Le fichier ${fichier} a ete envoye avec succes a `date +%T`" >> ${ficlog}
              echo "${S_PROCEXE}: Le fichier ${fichier} contenant $nbenr enregistrements a ete envoye avec succes le `date +%Y-%m-%d` a `date +%T` " >> $ficctl
            else
               echo "${S_PROCEXE}:Erreur de copie du fichier ${fichier} dans UNXENVOIE , il n'est par consequent pas parti" >> ${ficlog}
               nocp=1
          fi
        else
           echo "${S_PROCEXE}:Le fichier ${fichier} n existe pas dans UNXTMP" >> ${ficlog}
      fi
  fi
done
#Verification que la copie vers UNXENVOIE est bien passe
if [ $nocp -eq 1 ];then
echo "${S_PROCEXE}:Probleme de copie de fichier vers UNXENVOI" >> ${ficlog}
exit 1
fi
echo "${S_PROCEXE}:Fin du ${script} le `date +%d-%b-%Y` a `date +%T` " >> ${ficlog}
#-----
#----- Fin du job
