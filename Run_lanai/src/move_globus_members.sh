#!/bin/bash

. ./globus_tools.sh

myfile=$1
repini=$2
repout=$3
tfname=$4

ls ${repini}/m*/${myfile} > transfer_globus_tmp
globus_transfer_poseidon2ncar transfer_globus_tmp ${repini} ${repout} move_${tfname}

rm transfer_globus_tmp transfer_globus_tmp.transfer
