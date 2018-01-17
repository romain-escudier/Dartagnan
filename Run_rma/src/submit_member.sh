#!/bin/bash


. ./functions.sh
. ./parameters

nnn=$1
cycle=$(tail -n 1  ${SCRATCHDIR}/Logs/submit.log | awk -F "cycle " '{print $2}' | awk '{print $1}')
printf -v disp_cycle "%05d" ${cycle}

# Clean the filt files
rm ${SCRATCHDIR}/Tempfiles/m${nnn}/*

#---------------------------------------------------------------------------------------------#
# 1. submit ensemble members

# Run the preparation code (copy filt files)
output=$( ${SUBMIT} < ${SCRATCHDIR}/Tempfiles/roms_prepare_member_${nnn}.sub )
dep_id=$(./get_id_dependency.sh "$output" "" $CLUSTER)

# Run the ROMS code   
cat ${SCRATCHDIR}/Jobfiles/${SIMU}_roms_advance_member.sub | sed -e "s;<MEMBER>;$nnn;g" \
                                                        -e "s;<DEPLIST>;${dep_id};g" \
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
dep_id=$(./get_id_dependency.sh "$output" "" $CLUSTER)

# Run the post-processing (netcdf4 + copy of filt files)
cat ${SCRATCHDIR}/Jobfiles/${SIMU}_roms_post_member.sub | sed -e "s;<MEMBER>;$nnn;g" \
                                                     -e "s;<DEPLIST>;${dep_id};g" \
                                                     -e "s;<NCORES>;1;g"\
                                                     -e "s;<TYPENODE>;${TYPENODE_ROMS};g"\
                                                     -e "s;<WALLTIME>;00:10;g" \
                                                     -e "s;<CYCLE>;${cycle};g" \
                                                     -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
                                                     -e "s;<JOBNAME>;roms_post_${nnn}_c${disp_cycle}_${SIMU};g" \
                                                     -e "s;<LOGNAME>;roms_post_c${disp_cycle}_m${nnn};g" \
                                                     -e "s;<QUEUE>;${QUEUE_PREP};g" \
                                                     -e "s;<PROJECTCODE>;${PROJECT};g" \
> ${SCRATCHDIR}/Tempfiles/roms_post_member_${nnn}.sub
# Get the id of the job and keep it in listjobids (for the dependency of the analysis)
output=$( ${SUBMIT} < ${SCRATCHDIR}/Tempfiles/roms_post_member_${nnn}.sub )
dep_id=$(./get_id_dependency.sh "$output" "" $CLUSTER)

#---------------------------------------------------------------------------------------------#
# 2. submit assimilation step

cat ${SCRATCHDIR}/Jobfiles/${SIMU}_analysis.sub | sed -e "s;<DEPLIST>;"${dep_id}";g" \
                                             -e "s;<CYCLE>;${cycle};g" \
                                             -e "s;<DISPCYCLE>;${disp_cycle};g" \
                                             -e "s;<NCORES>;${NCORES_DART};g"\
                                             -e "s;<TYPENODE>;${TYPENODE_DART};g"\
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
cat ${SCRATCHDIR}/Jobfiles/${SIMU}_submit_next.sub | sed -e "s;<DEPLIST>;"$dep_id";g" \
                                                -e "s;<CYCLE>;${cycle};g" \
                                                -e "s;<DISPCYCLE>;${disp_cycle};g" \
                                                -e "s;<NCORES>;1;g"\
                                                -e "s;<TYPENODE>;${TYPENODE_DART};g"\
                                                -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
                                                -e "s;<WALLTIME>;00:05;g" \
                                                -e "s;<JOBNAME>;subnext_c${disp_cycle}_${SIMU};g" \
                                                -e "s;<LOGNAME>;subnext_c${disp_cycle};g" \
                                                -e "s;<QUEUE>;${QUEUE};g" \
                                                -e "s;<PROJECTCODE>;${PROJECT};g" \
> ${SCRATCHDIR}/Tempfiles/submit_next.sub
${SUBMIT} < ${SCRATCHDIR}/Tempfiles/submit_next.sub > /dev/null





