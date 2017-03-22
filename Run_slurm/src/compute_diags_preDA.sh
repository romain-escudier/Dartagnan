#!/bin/bash

. ./parameters

cat ${SCRATCHDIR}/Compute_spread_timeserie.sub | sed -e "s;<SIMU>;${SIMU};g" \
                                                     -e "s;<PROJECTCODE>;${PROJECT};g" \
                                                     -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
> ${SCRATCHDIR}/Tempfiles/Compute_spread_timeserie.sub

${SUBMIT} < ${SCRATCHDIR}/Tempfiles/Compute_spread_timeserie.sub




