#!/bin/bash


. ./functions.sh
. ./parameters

cycle=$1
printf -v disp_cycle "%05d" ${cycle}

#---------------------------------------------------------------------------------------------#
# 2. submit assimilation step

cat ${SCRATCHDIR}/Jobfiles/${SIMU}_analysis.sub | sed -e "/<DEPLIST>/d"\
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






