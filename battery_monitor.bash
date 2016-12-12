#!/bin/bash

trap resetSettings EXIT;


delay=0;
iter_max="one";
iterations="zero";

case "${1}" in
	"loop")
		delay=${2:-1};
		iter_max="forever";
	;;
	*)
		
	;;
esac;

#echo -ne "\e[?25l";

dir="/sys/class/power_supply";
batts=$(ls ${dir}|grep BAT);
batts_cnt=$(echo "${batts}"|wc -w);
CP="0";
CPD="0";
REM="--";


function clearLinesUp {
    local count=${1:-0};
    local c=0;

    while [[ ${c} -lt ${count} ]] ; do
        c=$((${c}+1));
        printf "\r\x1b[1A\x1b[2K\r";
    done;
}

function hideCursor {
    printf "\x1b[?25l";
}
function showCursor {
    printf "\x1b[?25h";
}





function resetSettings {
#	echo -ne "\e[?25h";
    showCursor;
}



hideCursor;


while [ "${iterations}" != "${iter_max}" ] ; do 
	for batt in ${batts}; do 
		read I   < ${dir}/${batt}/current_now        2>/dev/null || I="0"; 
		read U   < ${dir}/${batt}/voltage_now        2>/dev/null || U="0"; 
		read S   < ${dir}/${batt}/status             2>/dev/null || S="unknown";
		read CN  < ${dir}/${batt}/charge_now         2>/dev/null || CN="0";
		read CF  < ${dir}/${batt}/charge_full        2>/dev/null || CF="0";
		read CAP < ${dir}/${batt}/capacity           2>/dev/null || CAP="?"; 
		read CFD < ${dir}/${batt}/charge_full_design 2>/dev/null || CFD="0";
		
		[ "${CP}" != "${CN}" ] && {
			DATE=$(date +%s);
			
			[ "${CPD}" != "0" ] && {
				[[ ${CP} -gt ${CN} ]] && {
					REMs=$[${CN}/((${CP}-${CN})/(${DATE}-${CPD}))];
				} || {
					REMs=$[(${CF}-${CN})/((${CN}-${CP})/(${DATE}-${CPD}))];
				}
				
				REMh=$[${REMs}/60/60];
				REMm=$[${REMs}/60 - ${REMh}*60];
				REMs=$[${REMs} - ${REMh}*60*60 - ${REMm}*60];
				
#				REM="${REMh}:${REMm}:${REMs}";
#				echo "${REM}";
			}
			
			CPD=${DATE};
			CP=${CN};
			
		}

		
		echo |awk            \
			-v S=${S}    \
			-v CN=${CN}  \
			-v CF=${CF}  \
			-v CFD=${CFD}\
			-v Rh=${REMh}\
			-v Rm=${REMm}\
			-v Rs=${REMs}\
			-v CAP=${CAP}\
			-v I=${I}    \
			-v U=${U}    \
			-v B=${batt} \
		'{
			if (Rh != "" || Rm != "" || Rs != "" ) 
				REM=sprintf("remaining time %.2d:%.2d:%.2d", Rh, Rm, Rs);
            health=sprintf("health %.1f%", CF*100/CFD)
			printf "\r\x1b[2K" B " (" S " - " CN * 100 / CF "% "REM"), "health": " U/1000000"V " I/1000000"A " U*I/1000000000000"W\n"
		}'; 
			#if(CN != CP){REMs=systime()-CPD; REMs=CN/((CP-CN)/(systime()-CPD)); REMh=int(REMs/60/60); REMm=int((REMs/60)-(REMh*60)); REMs=int(REMs-(REMh*60*60)-(REMm*60)); };
			#printf "" B " (" S " - " CN * 100 / CF "%, REM="REMh":"REMm":"REMs"): " U/1000000"V " I/1000000"A " U*I/1000000000000"W      \r"
		#'{printf "" B " (" S " - " CAP "%): " U/1000000"V " I/1000000"A " U*I/1000000000000"W      \r"}'; 


	done; 
	sleep ${delay}; 
    clearLinesUp ${batts_cnt};
	iterations="one";
done
echo;






