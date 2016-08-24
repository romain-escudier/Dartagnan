#!/bin/bash
#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Cycle                                                                                       #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

if [ ! $# == 1 ] ; then echo 'this script needs the cycle number as an argument' ; exit 1 ; fi

cycle=$1

. ./functions.sh
. ./parameters

echo "running cycle $cycle of $NCYCLES"

if (( $cycle > $NCYCLES )) ; then 
   ./postprod_dart_obs.sh
   echo 'Completed' ; 
   exit 0 ; 
fi

#---------------------------------------------------------------------------------------------#
# 1. submit ensemble members

listjobids=""
printf -v disp_cycle "%03d" ${cycle}

for kmem in $( seq 1 $NMEMBERS ) ; do

   printf -v nnn "%03d" $kmem
   

   cat ${SCRATCHDIR}/generic_roms_advance_member.sub | sed -e "s/<MEMBER>/$nnn/g" \
                                                           -e "s;<CYCLE>;${cycle};g" \
                                                           -e "s;<DISPCYCLE>;${disp_cycle};g" \
                                                           -e "s;<NCORES>;${NCORES_ROMS};g"\
                                                           -e "s;<TYPENODE>;${TYPENODE};g"\
                                                           -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
   > ${SCRATCHDIR}/Tempfiles/roms_advance_member_${nnn}.sub
   
   output=$( sbatch < ${SCRATCHDIR}/Tempfiles/roms_advance_member_${nnn}.sub )
   id=$( echo $output | awk '{ print $NF }' )
   listjobids="$listjobids:$id"

done

#---------------------------------------------------------------------------------------------#
# 2. submit assimilation step

cat ${SCRATCHDIR}/generic_analysis.sub | sed -e "s/<DEPLIST>/$listjobids/g" \
                                             -e "s;<CYCLE>;${cycle};g" \
                                             -e "s;<DISPCYCLE>;${disp_cycle};g" \
                                             -e "s;<TYPENODE>;${TYPENODE};g"\
                                             -e "s;<NCORES>;${NCORES_DART};g"\
                                             -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
> ${SCRATCHDIR}/Tempfiles/analysis.sub
sbatch < ${SCRATCHDIR}/Tempfiles/analysis.sub

