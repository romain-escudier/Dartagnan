#!/bin/bash

. ./parameters

cat ${SCRATCHDIR}/Jobfiles/Rapatriement.sub | sed -e "s;<SIMU>;${SIMU};g" \
                                                     -e "s;<PROJECTCODE>;${PROJECT};g" \
                                                     -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
> ${SCRATCHDIR}/Tempfiles/Rapatriement_tmp.sub

${SUBMIT} < ${SCRATCHDIR}/Tempfiles/Rapatriement_tmp.sub




