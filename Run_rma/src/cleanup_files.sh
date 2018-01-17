#!/bin/bash

# Load simulation parameters
. ./parameters
. ./functions.sh

# Time parameters
enddate=$1

# Directories
dir_prior=${SCRATCHDIR}/Outputs/Prior/
dir_analy=${SCRATCHDIR}/Outputs/Reanalysis/

# Prefixes
prefix_prior=${SIMU}_rst_
prefix_analy=${SIMU}_rstana_

# Length of time period
if [ -z "$enddate" ]; then
   N_cycles=99999999999999999999999999999
else
   N_cycles=$(get_timediff_dates $STARTDATE $enddate)
   echo $N_cycles
fi

###################################################
# Remove all before N-3
###################################################
# Get last file created
printf -v NMEM "%03d" ${NMEMBERS}
cd ${dir_prior}/m${NMEM}/
file_list=$(ls ${prefix_prior}*.nc)
last_file=$(echo $file_list | awk -F " " '{print $NF}')
# Deduce last date
last_date=${last_file#${prefix_prior}}
last_date=${last_date%.nc}
# Only remove until last date - 3
N_cycles_test=$(get_timediff_dates $STARTDATE $last_date)
if (( $N_cycles > $(($N_cycles_test-3)) )); then
   N_cycles=$(($N_cycles_test-3))
fi
enddate=$(get_date_from_cycle ${N_cycles} $STARTDATE 1)

###################################################
# Do the cleaning
###################################################
# Ask for confirmation
read -r -p "Removing files from $STARTDATE to $enddate in ${SCRATCHDIR}/Outputs/: Is this OK? [y/N]" response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
then
   # Loop on members
   for kmem in $( seq 1 $NMEMBERS ) ; do
      printf -v nnn "%03d" $kmem
      echo "Member ${nnn} :"
      printf "keep : "
      
      # Remove priors
      cd ${dir_prior}/m${nnn}/
      
      for cycle in $(seq 0 $N_cycles); do
         date_tmp=$(get_date_from_cycle ${cycle} $STARTDATE 1)
         date_next=$(get_date_from_cycle $((${cycle}+1)) $STARTDATE 1)
         dday=$(str2num ${date_next:6:2})
         filename=${prefix_prior}${date_tmp}.nc
         if [ -f ${filename} ]; then
            rm ${filename}
         fi
      done

      # Remove analysis
      cd ${dir_analy}/m${nnn}/

      for cycle in $(seq 0 $N_cycles); do
         date_tmp=$(get_date_from_cycle ${cycle} $STARTDATE 1)
         date_next=$(get_date_from_cycle $((${cycle}+1)) $STARTDATE 1)
         dday=$(str2num ${date_next:6:2})
         filename=${prefix_analy}${date_tmp}.nc
         if (( dday == 1 )); then
            printf "${date_tmp} "
         else
            if [ -f ${filename} ]; then
               rm ${filename}
            fi
         fi
      done

      # Remove filters
      cd ${SCRATCHDIR}/Outputs/Filtfiles/m${nnn}/

      for cycle in $(seq 0 $N_cycles); do
         date_tmp=$(get_date_from_cycle ${cycle} $STARTDATE 1)
         date_next=$(get_date_from_cycle $((${cycle}+1)) $STARTDATE 1)
         dday=$(str2num ${date_next:6:2})
         if (( dday > 1 )); then
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

