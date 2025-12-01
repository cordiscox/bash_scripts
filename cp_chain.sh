#!/bin/bash

orig_batch=""
new_batch=""
new_batch_upr=()
new_batch_desc=""
new_session_last=()
c=0

clear

if [  $# != 0 ]; then
        echo -e "\n[+] Execute only the script without parameters\n"
        exit 1
fi

echo -e "\n[*] Type the name of the session to copy: " && read -r orig_batch
echo -e "\n[*] Type the name of the new session: " && read -r new_batch
echo -e "\n[*] Type the description of the new batch: " && read -r new_batch_desc

orig_batch_upr=( $(uxshw ses ses=${orig_batch} | grep "upr" | awk '{print $4}' | tr '\n' ' ') )
serv_mu=$(uxshw tsk ses=${orig_batch} mu=* upr=* NOMODEL | grep "mu" | grep -v "Commande" | head -n 1 | awk '{print $4}')

clear

for i in ${orig_batch_upr[@]}; do
        new_batch_upr[c]=${new_batch}${i: -3}
        let c++
done

for x in "${orig_batch_upr[@]}"; do
        if [[ "${x: -3}" == U09 ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - DEBUT\"
        elif [[ "${x: -3}" == C0* ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - COLLECT\"
        elif [[ "${x: -3}" == P0* ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - REPILOT\"
        elif [[ "${x: -3}" == A0* ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - ACUSE OF RECEPTION\"
        elif [[ "${x: -3}" == 0*0 ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - ABAP\"
        elif [[ "${x: -3}" == M0* ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - MAD\"
        elif [[ "${x: -3}" == E0* ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - ENVOI\"
        elif [[ "${x: -3}" == L00 ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - LAUNCH\"
        elif [[ "${x: -3}" == U89 ]]; then
                uxdup UPR EXP UPR="${x}" VUPR=000 TUPR="${new_batch}${x: -3}" TVUPR=000 TLABEL=\"${new_batch_desc} - FIN\"
        fi
done

for z in "${!new_batch_upr[@]}"; do
        if [[ "${new_batch_upr[z]: -3}" != U89 ]]; then
                new_session_last+=" FATHER=${new_batch_upr[z]} SONOK=((${new_batch_upr[((z + 1))]}))"
        fi
done

uxadd ses ses="${new_batch}" LABEL="${new_batch_desc}" HEADER=${new_batch_upr[0]}${new_session_last}

uxdup TSK EXP SES="${orig_batch}" UPR="${orig_batch_upr[0]}" VUPR=000 MU="${serv_mu}" TSES="${new_batch}" TUPR="${new_batch_upr[0]}" TVUPR=000 TMU="${serv_mu}" TNOMODEL
