#!/bin/bash

. ./parameters

set -x

rep_hsi=/home/romaines/Data/
file_name=$1
rep_out=$2
rep_ini=${rep_hsi}/$3

ACCOUNT=$PROJECT



cd ${rep_out}

for kmem in $( seq 1 $NMEMBERS ) ; do
   printf -v nnn "%03d" $kmem
   echo "Moving file : HSI:${rep_ini}/m${nnn}/$filename $rep_out/m${nnn}/"
   cd m${nnn}/
   hsi -a $ACCOUNT "cd ${rep_ini}/m${nnn}; cget $file_name"


done


