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
   

   cat ${SCRATCHDIR}/${SIMU}_roms_advance_member.sub | sed -e "s/<MEMBER>/$nnn/g" \
                                                           -e "s;<CYCLE>;${cycle};g" \
                                                           -e "s;<DISPCYCLE>;${disp_cycle};g" \
                                                           -e "s;<NCORES>;${NCORES_ROMS};g"\
                                                           -e "s;<TYPENODE>;${TYPENODE_ROMS};g"\
                                                           -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
                                                           -e "s;<WALLTIME>;${TLIM_ROMS};g" \
                                                           -e "s;<JOBNAME>;roms_${nnn}_c${disp_cycle}_${SIMU};g" \
                                                           -e "s;<LOGNAME>;roms_advance_c${disp_cycle}_m${nnn};g" \
                                                           -e "s;<QUEUE>;${QUEUE};g" \
                                                           -e "s;<PROJECTCODE>;${PROJECT};g" \
   > ${SCRATCHDIR}/Tempfiles/roms_advance_member_${nnn}.sub
   
   output=$( ${SUBMIT} < ${SCRATCHDIR}/Tempfiles/roms_advance_member_${nnn}.sub )
   if [ ${CLUSTER_NAME} = "triton" ] ; then
      id=$( echo $output | awk '{ print $NF }' )
   else
      id=$( echo $output | awk '{ print 2 }' )
   fi
   listjobids="$listjobids:$id"

done

#---------------------------------------------------------------------------------------------#
# 2. submit assimilation step

cat ${SCRATCHDIR}/${SIMU}_analysis.sub | sed -e "s/<DEPLIST>/$listjobids/g" \
                                             -e "s;<CYCLE>;${cycle};g" \
                                             -e "s;<DISPCYCLE>;${disp_cycle};g" \
                                             -e "s;<TYPENODE>;${TYPENODE_DART};g"\
                                             -e "s;<NCORES>;${NCORES_DART};g"\
                                             -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
                                             -e "s;<WALLTIME>;${TLIM_DART};g" \
                                             -e "s;<JOBNAME>;ana_c${disp_cycle}_${SIMU};g" \
                                             -e "s;<LOGNAME>;analysis_c${disp_cycle};g" \
                                             -e "s;<QUEUE>;${QUEUE};g" \
                                             -e "s;<PROJECTCODE>;${PROJECT};g" \
> ${SCRATCHDIR}/Tempfiles/analysis.sub
${SUBMIT} < ${SCRATCHDIR}/Tempfiles/analysis.sub















