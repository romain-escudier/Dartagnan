#!/bin/bash

. ./setup_parameters

# Current directory
CURRENTDIR=$(pwd)
DARTMNGDIR=${CURRENTDIR%/*/*}/

# Simulation directory
SIMUDIR=${CURRENTDIR}/${SIMUNAME}/

# Make directory for simulation
mkdir ${SIMUDIR}/
mkdir ${SIMUDIR}/src/

# Copy template files
cp ${DARTMNGDIR}/template/varinfo.dat ${SIMUDIR}/
cp ${DARTMNGDIR}/src/main.ksh ${SIMUDIR}/
cp ${DARTMNGDIR}/src/clean.sh ${SIMUDIR}/


cat ${DARTMNGDIR}/template/parameters.template | sed -e "s;<SIMUNAME>;${SIMUNAME};g"     \
                                                     -e "s;<SCRATCHDIR>;${SCRATCHDIR};g" \
                                                     -e "s;<WORKINGDIR>;${SIMUDIR};g" \
                                                     -e "s;<DARTMNGDIR>;${DARTMNGDIR};g" \
> ${SIMUDIR}/parameters


# Create build script : ROMS
cat ${DARTMNGDIR}/template/build.bash.template | sed -e "s;<ROMS_APP>;$ROMSAPP;g"\
                                                     -e "s;<ROMS_DIR>;$ROMSDIR;g"\
                                                     -e "s;<MY_TMPDIR>;$SCRATCHDIR;g"\
> ${SIMUDIR}/build.bash
chmod 755 ${SIMUDIR}/build.bash


# Create build script : DART

cat ${DARTMNGDIR}/template/build_dart.bash.template | sed -e "s;<DARTDIR>;$DARTDIR;g"\
                                                          -e "s;<WORKDIR>;$ROMSDIR;g"\
                                                          -e "s;<SCRATCHDIR>;$SCRATCHDIR;g"\
> ${SIMUDIR}/build_dart.bash
chmod 755 ${SIMUDIR}/build_dart.bash


