#!/bin/bash

DARTDIR=/glade/p/work/romaines/Tools/DART/trunk_new2/
WORKDIR=/glade/u/home/romaines/Projects/dartagnan/Run_slurm/user/romain/NWA-RE.REANA55/
SCRATCHDIR=/glade/scratch/romaines//dart/tmpdir_NWA-RE.REANA55/

MYDIR=$(pwd)

cd ${DARTDIR}/models/ROMS/work/

./quickbuild.csh -mpi

mkdir -p ${WORKDIR}/dart_exe/
mkdir -p ${SCRATCHDIR}/Exe/
cp roms_to_dart filter dart_to_roms obs_diag obs_seq_to_netcdf fill_inflation_restart ${WORKDIR}/dart_exe/
cp roms_to_dart filter dart_to_roms obs_diag obs_seq_to_netcdf fill_inflation_restart ${SCRATCHDIR}/Exe/

cd ${MYDIR}

