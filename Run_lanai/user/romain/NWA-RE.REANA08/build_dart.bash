#!/bin/bash

DARTDIR=/home/romain/Projects/DART/trunk/
WORKDIR=/t6/workdir/romain/dartagnan/Run_slurm/user/romain/NWA-RE.REANA08/
SCRATCHDIR=/t0/scratch/romain/dart/tmpdir_NWA-RE.REANA08/

MYDIR=$(pwd)

cd ${DARTDIR}/models/ROMS/work/

./quickbuild.csh -mpi

mkdir -p ${WORKDIR}/dart_exe/
mkdir -p ${SCRATCHDIR}/Exe/
cp roms_to_dart filter dart_to_roms obs_diag obs_seq_to_netcdf ${WORKDIR}/dart_exe/
cp roms_to_dart filter dart_to_roms obs_diag obs_seq_to_netcdf ${SCRATCHDIR}/Exe/

cd ${MYDIR}

