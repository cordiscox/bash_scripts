#!/bin/ksh
set -vx
#-------------------------------------------------------------------------------
#-----             -=- Reception Script -=-
#-------------------------------------------------------------------------------
#  Module name           : reception.sh
#  Module description    : Common interface file reception script, extraction is done on the name of the file(s) extracted from $U
#                           and declared in the IDF reception table (/users/prd00/exploit/data/prdfcid2.cfg)
#  Version number        : V1.0
#-----
#
# Module operation description:
#
# - verification of the existence of the IDF
# - file reception
# - file backup in UNXSAVDAT and UNXSAVDAT/N_tmp
#
#---------------------------------------------------------------------------
PRDSPECIF=`echo $S_PROCEXE | cut -c 1-3 `
prdspecif=`echo ${PRDSPECIF}|tr "[:upper:]" "[:lower:]"`
FILE=`echo $S_CODSESS | cut -c 4- `
date_trait="`date +%d-%b-%Y`"
time_trait="`date +%T`"
logfile=$UNXLOG/"`date +%d-%b-%Y`"-"`date +%T`"-"$S_PROCEXE".log
script="reception.sh"
#SFR definition of the .cfg perl file
cfgfile=$UNXEXDATA/"$prdspecif"fcid2.cfg
ctlfile=$UNXTMP/"$UNXPRDAPPLI"fpZ5s2.dat


#-----
#  Function: file access control
#-----
sub_pgm1 () {
    if mkdir ${ctlfile}_lock 2> /dev/null; then
        sub_pgm2
    else 
        while [ -d ${ctlfile}_lock ]; do
            sleep 1
        done
        sub_pgm2
    fi
}

sub_pgm2 () {
	echo "${S_PROCEXE}: The file ${file} containing $num_records records was successfully received on `date +%Y-%m-%d` at `date +%T` " >> $ctlfile
	rmdir ${ctlfile}_lock 2> /dev/null
}

#-----
#  Start of the job trecept.sh
#-----
echo "${S_PROCEXE}:Starting ${script} on `date +%d-%b-%Y` at `date +%T` " >> ${logfile}
#-----
#Verification of the definition of files present in the CFT config
for testfile in `ls ${UNXRECEPT}|grep ${prdspecif}fi${FILE}` ;do
    if [ `grep $testfile $cfgfile |wc -l` -eq 0 ];then
		echo "${S_PROCEXE}:The file $testfile cannot be processed in reception because it is not defined in CFT">> ${logfile}
		#echo "$S_CODSESS : $S_PROCEXE cannot process the file ${UNXRECEPT}/${testfile} in reception because it is not defined in CFT"|mailx -s "CFT Alert: Undefined file" acvcsdi@mpsa.com
		exit 1
    fi
done

for file in `grep "${prdspecif}fi${FILE}" $cfgfile| awk '{print $1}' `
do
  if [ `echo "${file}" | wc -w` -eq 0 ]
    then
      exit 1
    else
      cfg=`grep ${file} $cfgfile`
      idf=`echo ${cfg} | awk '{print $2}'`
      mode=`echo ${cfg} | awk '{print $3}'`

      echo "${S_PROCEXE}:Starting CFT IDF ${idf} reception process for file ${file} at `date +%T`">> ${logfile}
      $CFTEXSCRIPT/cft_0ma.pl -mode=${mode} "${file}"
      sleep 20
      if [ -f "${UNXRECEPT}/${file}" ]
        then
          cd ${UNXRECEPT}
          chmod 666 ${file} >> ${logfile}
          echo "${S_PROCEXE}:The file ${file} was successfully received at `date +%T`" >> ${logfile}
          ret=`$UNXEXSCRIPT/generic/RETENTION_FILE ${S_CODSESS}`
          saved_file_name="${date_trait}"-"${time_trait}"-`echo ${file}`.sav
          cp -pr "${file}" "$UNXSAVDAT/${saved_file_name}"
          cp1=$?
          cp -pr "${file}" "$UNXSAVE/${ret}tmp/${saved_file_name}"
          cp2=$?
          mv "$UNXSAVE/${ret}tmp/${saved_file_name}" "$UNXSAVE/${ret}/${saved_file_name}"
          mv1=$?
          ctrl=`expr $cp1 + $cp2 + $mv1`
          if [ $ctrl -eq 0 ];then
			echo "${S_PROCEXE}:The file ${file} has been backed up" >> ${logfile}
          else
			echo "${S_PROCEXE}:The backup of the file ${file} encountered a problem" >> ${logfile}
			exit 1
          fi
          mv ${file} $UNXTMP/
          if [ $? -ne 0 ]
            then
              echo "${S_PROCEXE}:Error copying the file ${file} to UNXTMP" >> ${logfile}
              exit 1
            else
              num_records=`wc -l "$UNXTMP/${file}" | awk '{print $1}'`
              sub_pgm1
              echo "${S_PROCEXE}:The file ${file} is copied to UNXTMP, it contains $num_records records " >> ${logfile}
          fi
        else
          echo "${S_PROCEXE}:The file ${file} does not exist in UNXRECEPT" >> ${logfile}
      fi
  fi
done

echo "${S_PROCEXE}:End of ${script} on `date +%d-%b-%Y` at `date +%T` " >> ${logfile}
exit 0
