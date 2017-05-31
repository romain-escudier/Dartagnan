#!/bin/bash

# Load simulation parameters
. ./parameters
. ./functions.sh

# Time parameters
enddate=$1

# Length of time period
if [ -z "$enddate" ]; then
   N_cycles=99999999999999999999999999999
else
   N_cycles=$(get_timediff_dates $STARTDATE $enddate)
   echo $N_cycles
fi

# Check last file (remove all before N-3)
cd ${SCRATCHDIR}/Outputs/Filtfiles/m030/
file_list=$(ls ocean_filu_01_*)
last_file=$(echo $file_list | awk -F " " '{print $NF}')
last_date=${last_file#ocean_filu_01_}
last_date=${last_date%.nc}
N_cycles_test=$(get_timediff_dates $STARTDATE $last_date)
if (( $N_cycles > $(($N_cycles_test-3)) )); then
   N_cycles=$(($N_cycles_test-3))
fi
enddate=$(get_date_from_cycle ${N_cycles} $STARTDATE 1)

read -r -p "Removing files from $STARTDATE to $enddate in ${SCRATCHDIR}/Outputs/Filtfiles/: Is this OK? [y/N]" response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
   for kmem in $( seq 1 $NMEMBERS ) ; do
      printf -v nnn "%03d" $kmem
      echo "Member ${nnn} :"
      printf "keep : "
      
      cd ${SCRATCHDIR}/Outputs/Filtfiles/m${nnn}/
      
      for cycle in $(seq 0 $N_cycles); do
         date_tmp=$(get_date_from_cycle ${cycle} $STARTDATE 1)
         date_next=$(get_date_from_cycle $((${cycle}+1)) $STARTDATE 1)
         dday=$(str2num ${date_next:6:2})
         if (( dday == 1 )); then
            printf "${date_tmp} "
         else
            if [ -f ocean_filw_01_${date_tmp}.nc ]; then
               rm ocean_fil*_01_${date_tmp}.nc
            fi
         fi
      done
      echo " "
   done
else
    echo "We do nothing."
fi

