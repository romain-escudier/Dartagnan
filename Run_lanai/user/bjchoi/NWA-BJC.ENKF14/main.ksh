#!/bin/bash
#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Main                                                                                        #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

. ./parameters

# Prepare scratch directory
mkdir -p ${SCRATCHDIR}/Logs/
mkdir -p ${SCRATCHDIR}/Tempfiles/
mkdir -p ${SCRATCHDIR}/Roms_files/
mkdir -p ${SCRATCHDIR}/Exe/
mkdir -p ${SCRATCHDIR}/Outputs/Average/
mkdir -p ${SCRATCHDIR}/Outputs/History/
mkdir -p ${SCRATCHDIR}/Outputs/Prior/
mkdir -p ${SCRATCHDIR}/Outputs/Reanalysis/
mkdir -p ${SCRATCHDIR}/Outputs/Tmpdir/

for kmem in $( seq 1 $NMEMBERS ) ; do
   printf -v nnn "%03d" $kmem
   mkdir -p ${SCRATCHDIR}/Outputs/Average/m${nnn}/
   mkdir -p ${SCRATCHDIR}/Outputs/History/m${nnn}/
   mkdir -p ${SCRATCHDIR}/Outputs/Prior/m${nnn}/
   mkdir -p ${SCRATCHDIR}/Outputs/Reanalysis/m${nnn}/

   init_file_tmp=$( echo ${INITFILE} | sed -e "s;XXX;${nnn};")
   ln -fs ${init_file_tmp} ${SCRATCHDIR}/Outputs/Reanalysis/m${nnn}/${SIMU}_ini_${STARTDATE}.nc
done

# Get parameters
cp ${WORKINGDIR}/parameters ${SCRATCHDIR}/
cp ${WORKINGDIR}/varinfo.dat ${SCRATCHDIR}/
cp ${WORKINGDIR}/modules-used ${SCRATCHDIR}/

# Get scripts
cp ${DARTMNGDIR}/src/* ${SCRATCHDIR}/
## Get executables for analysis
#cp ${WORKINGDIR}/dart_exe/* ${SCRATCHDIR}/Exe/
# Get templates
cp ${DARTMNGDIR}/template/input.nml.default ${SCRATCHDIR}/
cp ${WORKINGDIR}/ocean_${SIMU}.in ${SCRATCHDIR}/


cd ${SCRATCHDIR}
echo "Creating working directory : $(pwd)"

# Lauch 1rst iteration of cycle
${SCRATCHDIR}/submit_cycle.sh $NSTART > ${SCRATCHDIR}/Logs/submit.log


