#!/bin/bash

DARTDIR=/home/bjchoi/MODELS/lanai
WORKDIR=/home/bjchoi/MODELS/ROMS-ESM
SCRATCHDIR=/t0/scratch/bjchoi/tmpdir_NWA-BJC.ENKF14/

MYDIR=${pwd}

cd ${DARTDIR}/models/ROMS/work/

./quickbuild.csh -mpi

mkdir -p ${WORKDIR}/dart_exe/
mkdir -p ${SCRATCHDIR}/Exe/
cp roms_to_dart filter dart_to_roms ${WORKDIR}/dart_exe/
cp roms_to_dart filter dart_to_roms ${SCRATCHDIR}/Exe/

cd ${MYDIR}

