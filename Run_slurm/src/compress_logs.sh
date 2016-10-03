#!/bin/bash

. ./parameters

cd ${SCRATCHDIR}/Logs/
for cycle in $( seq 1 $NCYCLES ) ; do
   printf -v disp_cycle "%03d" ${cycle}
   echo "Cycle ${disp_cycle}"
   
   if ls ${SCRATCHDIR}/Logs/roms_advance_c${disp_cycle}* 1>/dev/null 2>&1 ; then

      cd ${SCRATCHDIR}/Logs/
      tar -czf ${SCRATCHDIR}/Logs/log_c${disp_cycle}.tar.gz *c${disp_cycle}*
      rm ${SCRATCHDIR}/Logs/*c${disp_cycle}*

      cd ${SCRATCHDIR}/Logs/ROMS/
      tar -czf ${SCRATCHDIR}/Logs/roms_log_c${disp_cycle}.tar.gz *c${disp_cycle}*
      rm ${SCRATCHDIR}/Logs/ROMS/*c${disp_cycle}*

      cd ${SCRATCHDIR}/Logs/DART/
      tar -czf ${SCRATCHDIR}/Logs/dart_log_c${disp_cycle}.tar.gz *c${disp_cycle}*
      rm ${SCRATCHDIR}/Logs/DART/*c${disp_cycle}*
   fi
   
done



