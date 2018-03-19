#!/bin/bash

DARTDIR=/home/romain/Projects/DART/trunk/
WORKDIR=/home/romain/Projects/ROMS/
SCRATCHDIR=/t0/scratch/romain/dart/tmpdir_NWA-RE.REANA01/

MYDIR=${pwd}

cd ${DARTDIR}/models/ROMS/work/

./quickbuild.sh -mpi

mkdir -p ${WORKDIR}/dart_exe/
mkdir -p ${SCRATCHDIR}/Exe/
cp roms_to_dart filter dart_to_roms ${WORKDIR}/dart_exe/
cp roms_to_dart filter dart_to_roms ${SCRATCHDIR}/Exe/

cd ${MYDIR}

