#!/bin/bash

DARTDIR=/home/romain/Projects/DART/trunk/
WORKDIR=/t6/workdir/romain/dartagnan/Run_slurm/user/romain/NWA-RE.REANA01T/
SCRATCHDIR=/t0/scratch/romain/dart/tmpdir_NWA-RE.REANA01T/

MYDIR=$(pwd)

cd ${DARTDIR}/models/ROMS/work/

./quickbuild.csh -mpi

mkdir -p ${WORKDIR}/dart_exe/
mkdir -p ${SCRATCHDIR}/Exe/
cp roms_to_dart filter dart_to_roms ${WORKDIR}/dart_exe/
cp roms_to_dart filter dart_to_roms ${SCRATCHDIR}/Exe/

cd ${MYDIR}

