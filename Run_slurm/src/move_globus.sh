#!/bin/bash

NCAR_ID=d33b3614-6d04-11e5-ba46-22000b92c6ec
POSE_ID=adc7785a-290f-11e7-bc76-22000b9a448b

# Load simulation parameters
. ./parameters
. ./functions.sh
. ./globus_tools.sh

# Arguments
myfile=$1
repini=$2
repout=$3

rep_base=$(pwd)/

for kmem in $( seq 1 $NMEMBERS ) ; do
   printf -v nnn "%03d" $kmem

   rep_ini=${repini}/m${nnn}/
   rep_out=${repout}/m${nnn}/

   cd $rep_ini
   ls ${myfile} > source_tmp.lst

   globus_create_transfer_file source_tmp.lst ${rep_ini} ${rep_out}
   
   cat source_tmp.lst.transfer >> ${rep_base}mytransfer.lst
   rm source_tmp.lst source_tmp.lst.transfer

done

cat ${rep_base}mytransfer.lst | globus transfer --batch --preserve-mtime --label "yel-pos" $NCAR_ID $POSE_ID


