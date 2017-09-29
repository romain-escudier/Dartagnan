#!/bin/bash

. ./parameters

cat ${SCRATCHDIR}/Jobfiles/Make_nc4_diags.sub | sed -e "s;<SIMU>;${SIMU};g" \
                                           -e "s;<PROJECTCODE>;${PROJECT};g" \
                                           -e "s;<CURRENTDIR>;${SCRATCHDIR};g" \
> ${SCRATCHDIR}/Tempfiles/Make_nc4_diags.sub

${SUBMIT} < ${SCRATCHDIR}/Tempfiles/Make_nc4_diags.sub




