#!/bin/bash

#TODO add test if no argument (return help)
if [ "$#" -ne 1 ]; then
   echo "Error: you need to put one path to the directory of your runs"
   exit 1
fi


# Get run directory
DIRRUNS=$1

# Get Dartagnan directory
CURRENTDIR=$(pwd)/

# Create run directory
mkdir -p ${DIRRUNS}

# Copy setup files
cp ${CURRENTDIR}/Common_files/src/setup_simu.sh ${DIRRUNS}/
cat ${CURRENTDIR}/Common_files/template/setup_parameters \
	| sed -e "s;<DARTMNGDIR>;${CURRENTDIR};" \
> ${DIRRUNS}/setup_parameters

echo "Saving in $DIRRUNS"
