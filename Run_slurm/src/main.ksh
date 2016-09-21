#!/bin/bash
#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Main                                                                                        #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

. ./parameters

# Prepare scratch directories
mkdir -p ${SCRATCHDIR}/Logs/ROMS/
mkdir -p ${SCRATCHDIR}/Logs/DART/
mkdir -p ${SCRATCHDIR}/Tempfiles/
mkdir -p ${SCRATCHDIR}/Roms_files/
mkdir -p ${SCRATCHDIR}/Exe/
mkdir -p ${SCRATCHDIR}/Outputs/Average/
mkdir -p ${SCRATCHDIR}/Outputs/History/
mkdir -p ${SCRATCHDIR}/Outputs/Prior/
mkdir -p ${SCRATCHDIR}/Outputs/Reanalysis/
mkdir -p ${SCRATCHDIR}/Outputs/Tmpdir/
mkdir -p ${SCRATCHDIR}/Outputs/Filtfiles/
mkdir -p ${SCRATCHDIR}/Outputs/ObsOut/
mkdir -p ${SCRATCHDIR}/Outputs/Diags/


for kmem in $( seq 1 $NMEMBERS ) ; do
   printf -v nnn "%03d" $kmem
   mkdir -p ${SCRATCHDIR}/Outputs/Average/m${nnn}/
   mkdir -p ${SCRATCHDIR}/Outputs/History/m${nnn}/
   mkdir -p ${SCRATCHDIR}/Outputs/Prior/m${nnn}/
   mkdir -p ${SCRATCHDIR}/Outputs/Reanalysis/m${nnn}/
   mkdir -p ${SCRATCHDIR}/Outputs/Filtfiles/m${nnn}/

   #TODO Add case of restart from other simu
   ln -fs ${INITDIR}/m${nnn}/${INITFILE} ${SCRATCHDIR}/Outputs/Reanalysis/m${nnn}/${SIMU}_ini_${STARTDATE}.nc
done

# Get parameters
cp ${WORKINGDIR}/parameters ${SCRATCHDIR}/
cp ${WORKINGDIR}/varinfo.dat ${SCRATCHDIR}/
cp ${WORKINGDIR}/modules-used ${SCRATCHDIR}/

# Get templates
cp ${WORKINGDIR}/input_${SIMU}.nml ${SCRATCHDIR}/
cp ${WORKINGDIR}/ocean_${SIMU}.in ${SCRATCHDIR}/

# Get scripts
cp ${DARTMNGDIR}/src/*.sh ${SCRATCHDIR}/
# Get scripts to be submitted with header corresponding to cluster
cd ${DARTMNGDIR}/src/
sed "/<HEADER>/r header.${CLUSTER}" generic_analysis.sub \
        | sed -e "/<HEADER>/d" > ${SCRATCHDIR}/${SIMU}_analysis.sub
sed "/<HEADER>/r header.${CLUSTER}" generic_roms_advance_member.sub \
        | sed -e "/<HEADER>/d" -e "/<DEPLIST>/d" > ${SCRATCHDIR}/${SIMU}_roms_advance_member.sub # Also remove the dependency list

cd ${SCRATCHDIR}
echo "Creating working directory : $(pwd)"

# Launch 1rst iteration of cycle
${SCRATCHDIR}/submit_cycle.sh $NSTART > ${SCRATCHDIR}/Logs/submit.log


