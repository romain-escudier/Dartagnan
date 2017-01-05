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
printf -v disp_cycle "%03d" ${cycle}

# Check if finished + post-processing
if (( $cycle > $NCYCLES )) ; then 
   ./postprod_dart_obs.sh
   echo 'Completed' ; 
   exit 0 ; 
fi

#---------------------------------------------------------------------------------------------#
# 1. submit ensemble members

listjobids=""

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
   
   # Get the id of the job and keep it in listjobids (for the dependency of the analysis)
   output=$( ${SUBMIT} < ${SCRATCHDIR}/Tempfiles/roms_advance_member_${nnn}.sub )
   listjobids=$(./get_id_dependency.sh "$output" "$listjobids" $CLUSTER)
   if ! (( $? == 0 )); then
      echo $listjobids
      exit 1 
   fi

done

#---------------------------------------------------------------------------------------------#
# 2. submit assimilation step

cat ${SCRATCHDIR}/${SIMU}_analysis.sub | sed -e "s;<DEPLIST>;"$listjobids";g" \
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
output=$( ${SUBMIT} < ${SCRATCHDIR}/Tempfiles/analysis.sub )
dep_id=$(./get_id_dependency.sh "$output" "" $CLUSTER)

#---------------------------------------------------------------------------------------------#
# 3. submit script for the next step
cat ${SCRATCHDIR}/${SIMU}_submit_next.sub | sed -e "s;<DEPLIST>;"$dep_id";g" \
                                                -e "s;<CYCLE>;${cycle};g" \
                                                -e "s;<DISPCYCLE>;${disp_cycle};g" \
                                                -e "s;<TYPENODE>;${TYPENODE_DART};g"\
                                                -e "s;<NCORES>;1;g"\
                                                -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
                                                -e "s;<WALLTIME>;00:10;g" \
                                                -e "s;<JOBNAME>;subnext_c${disp_cycle}_${SIMU};g" \
                                                -e "s;<LOGNAME>;subnext_c${disp_cycle};g" \
                                                -e "s;<QUEUE>;${QUEUE};g" \
                                                -e "s;<PROJECTCODE>;${PROJECT};g" \
> ${SCRATCHDIR}/Tempfiles/submit_next.sub
${SUBMIT} < ${SCRATCHDIR}/Tempfiles/submit_next.sub





