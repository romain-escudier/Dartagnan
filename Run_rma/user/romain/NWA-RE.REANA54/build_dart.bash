#!/bin/bash

DARTDIR=/glade/p/work/romaines/Tools/DART/Manhattan/
WORKDIR=/glade/u/home/romaines/Projects/dartagnan/Run_rma/user/romain/NWA-RE.REANA54/
SCRATCHDIR=/glade/scratch/romaines//dart/tmpdir_NWA-RE.REANA54/

MYDIR=$(pwd)

cd ${DARTDIR}/models/ROMS/work/

./quickbuild.csh -mpi

mkdir -p ${WORKDIR}/dart_exe/
mkdir -p ${SCRATCHDIR}/Exe/
cp filter obs_diag obs_seq_to_netcdf ${WORKDIR}/dart_exe/
cp filter obs_diag obs_seq_to_netcdf ${SCRATCHDIR}/Exe/

cd ${MYDIR}

