#!/bin/bash

# Load simulation parameters
. ./parameters
. ./functions.sh

myfile=$1
repini=$2
repout=$3
tohost=$4

for kmem in $( seq 1 $NMEMBERS ) ; do
   printf -v nnn "%03d" $kmem
   echo "Member ${nnn} :"
   
   rep_ini=${repini}/m${nnn}/
   rep_out=${repout}/m${nnn}/
   
   rsync -havz --progress ${rep_ini}${myfile} ${tohost}:${rep_out}
done

