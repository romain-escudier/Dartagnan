#!/bin/bash

# Load simulation parameters
. ./parameters
. ./functions.sh

# Time parameters
enddate=$1
declare -i end_year=$(str2num ${enddate:0:4})
declare -i end_mont=$(str2num ${enddate:4:2})
declare -i end_dday=$(str2num ${enddate:6:2})

declare -i start_year=$(str2num ${STARTDATE:0:4})
declare -i start_mont=$(str2num ${STARTDATE:4:2})
declare -i start_dday=$(str2num ${STARTDATE:6:2})

# Length of time period
N_cycles=$(get_timediff_dates $STARTDATE $enddate)

echo "Removing files from $STARTDATE to $enddate in ${SCRATCHDIR}/Outputs/Filtfiles/"

for kmem in $( seq 1 $NMEMBERS ) ; do
   printf -v nnn "%03d" $kmem
   echo "Member ${nnn} :"
   
   cd ${SCRATCHDIR}/Outputs/Filtfiles/m${nnn}/
   
   for cycle in $(seq 0 $N_cycles); do
      date_tmp=$(get_date_from_cycle ${cycle} $STARTDATE 1)
      date_next=$(get_date_from_cycle $((${cycle}+1)) $STARTDATE 1)
      dday=$(str2num ${date_next:6:2})
      if (( dday == 1 )); then
         echo "keep ${date_tmp}"
      else
         if [ -f ocean_filw_01_${date_tmp}.nc ]; then
            rm ocean_fil*_01_${date_tmp}.nc
         fi
      fi
   done
done

