#!/bin/bash

# Load simulation parameters
. ./parameters
. ./functions.sh

YEAR=$1
printf -v MONTH "%02d" $2

echo "Year: $YEAR, month: $MONTH"

rep_globus=${SCRATCHDIR}/Outputs_GLOBUS/${YEAR}/${MONTH}/

# DART Diagnostics
mkdir -p ${rep_globus}/Diags/
mv ${SCRATCHDIR}/Outputs/Diags/*_${YEAR}${MONTH}* ${rep_globus}/Diags/

# Observation outputs
mkdir -p ${rep_globus}/ObsOut/
mv ${SCRATCHDIR}/Outputs/ObsOut/*.${YEAR}${MONTH}* ${rep_globus}/ObsOut/

# Inflation
mkdir -p ${rep_globus}/Reanalysis/Inflation/
mv ${SCRATCHDIR}/Outputs/Reanalysis/Inflation/dart_inf_*${YEAR}${MONTH}* ${rep_globus}/Reanalysis/Inflation/

for kmem in $( seq 1 $NMEMBERS ) ; do
   printf -v nnn "%03d" $kmem
   echo "Member ${nnn} :"
   
   # Averages
   rep_member=${SCRATCHDIR}/Outputs/Average/m${nnn}/
   rep_glob_member=${rep_globus}/Average/m${nnn}/
   mkdir -p ${rep_glob_member}
   mv ${rep_member}${SIMU}_avg_${YEAR}${MONTH}*.nc ${rep_glob_member}

   # Filt files
   rep_member=${SCRATCHDIR}/Outputs/Filtfiles/m${nnn}/
   rep_glob_member=${rep_globus}/Filtfiles/m${nnn}/
   mkdir -p ${rep_glob_member}
   mv ${rep_member}ocean_fil*_01_${YEAR}${MONTH}*.nc ${rep_glob_member}

   # Reanalysis
   rep_member=${SCRATCHDIR}/Outputs/Reanalysis/m${nnn}/
   rep_glob_member=${rep_globus}/Reanalysis/m${nnn}/
   mkdir -p ${rep_glob_member}
   mv ${rep_member}${SIMU}_rstana_${YEAR}${MONTH}*.nc ${rep_glob_member}


done

