#!/bin/bash

. ./setup_parameters

# Current directory
CURRENTDIR=$(pwd)

# Simulation directory
SIMUDIR=${CURRENTDIR}/${SIMUNAME}/

# Make directory for simulation
mkdir ${SIMUDIR}/
mkdir ${SIMUDIR}/src/

##########################################################################
# Copy template files
##########################################################################
# ROMS template files
cp ${DARTMNGDIR}/Common_files/template/varinfo.dat ${SIMUDIR}/
cat ${DARTMNGDIR}/Common_files/template/ocean_in.template \
		| sed -e "s;<TITLESIMU>;${APPLONG};g" \
		      -e "s;<SIMUAPP>;${ROMSAPP};g"   \
                      -e "s;<VARINFODIR>;${SCRATCHDIR};g"\
> ${SIMUDIR}/ocean_${SIMUNAME}.in

# Dart template files
cp ${DARTMNGDIR}/Run_${DARTVERSION}/template/input.nml.template ${SIMUDIR}/input_${SIMUNAME}.nml


# Main scripts 
cp ${DARTMNGDIR}/Common_files/src/main.sh ${SIMUDIR}/
cp ${DARTMNGDIR}/Common_files/src/clean.sh ${SIMUDIR}/

# Dartagnan parameters
cat ${DARTMNGDIR}/Common_files/template/parameters.template \
		| sed -e "s;<SIMUNAME>;${SIMUNAME};g"     \
                      -e "s;<SCRATCHDIR>;${SCRATCHDIR};g" \
                      -e "s;<WORKINGDIR>;${SIMUDIR};g" \
                      -e "s;<DARTMNGDIR>;${DARTMNGDIR};g" \
                      -e "s;<DARTVERSION>;${DARTVERSION};g" \
> ${SIMUDIR}/parameters

##########################################################################
# Create build script : ROMS
##########################################################################
cat ${DARTMNGDIR}/Common_files/template/build_roms.bash.template \
		| sed -e "s;<ROMS_APP>;${ROMSAPP};g"\
                      -e "s;<ROMS_DIR>;${ROMSDIR};g"\
                      -e "s;<MY_TMPDIR>;${SCRATCHDIR};g"\
> ${SIMUDIR}/build_roms.bash
chmod 755 ${SIMUDIR}/build_roms.bash


##########################################################################
# Create build script : DART
##########################################################################

cat ${DARTMNGDIR}/Run_${DARTVERSION}/template/build_dart.bash.template \
		| sed -e "s;<DARTDIR>;${DARTDIR};g"\
                      -e "s;<WORKDIR>;${SIMUDIR};g"\
                      -e "s;<SCRATCHDIR>;${SCRATCHDIR};g"\
> ${SIMUDIR}/build_dart.bash
chmod 755 ${SIMUDIR}/build_dart.bash




