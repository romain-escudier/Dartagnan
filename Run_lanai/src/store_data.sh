#!/bin/bash

. ./parameters

cat ${SCRATCHDIR}/Jobfiles/roms2hpss.sub | sed -e "s;<SIMU>;${SIMU};g" \
                                      -e "s;<PROJECTCODE>;${PROJECT};g" \
                                      -e "s;<NMEMBERS>;${NMEMBERS};g" \
                                      -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
> ${SCRATCHDIR}/Tempfiles/roms2hpss_filled.sub

${SUBMIT} < ${SCRATCHDIR}/Tempfiles/roms2hpss_filled.sub




