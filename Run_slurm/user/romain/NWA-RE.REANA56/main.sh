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
mkdir -p ${SCRATCHDIR}/Jobfiles/
mkdir -p ${SCRATCHDIR}/Exe/
mkdir -p ${SCRATCHDIR}/Outputs/Average/
mkdir -p ${SCRATCHDIR}/Outputs/History/
mkdir -p ${SCRATCHDIR}/Outputs/Prior/
mkdir -p ${SCRATCHDIR}/Outputs/Reanalysis/Inflation/
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
   #ln -fs ${INITDIR}/m${nnn}/${INITFILE} ${SCRATCHDIR}/Outputs/Reanalysis/m${nnn}/${SIMU}_ini_${STARTDATE}.nc
   ln -fs ${INITDIR}/${INITFILE} ${SCRATCHDIR}/Outputs/Reanalysis/m${nnn}/${SIMU}_ini_${STARTDATE}.nc
done

# Get parameters
cp ${WORKINGDIR}/parameters ${SCRATCHDIR}/
cp ${WORKINGDIR}/varinfo.dat ${SCRATCHDIR}/
cp ${WORKINGDIR}/modules-used ${SCRATCHDIR}/

# Get templates
cp ${WORKINGDIR}/input_${SIMU}.nml ${SCRATCHDIR}/
cp ${WORKINGDIR}/ocean_${SIMU}.in ${SCRATCHDIR}/

# Get gaussian random numbers
cp ${DARTMNGDIR}/utils/randn.txt ${SCRATCHDIR}/

# Get scripts
cp ${DARTMNGDIR}/src/*.sh ${SCRATCHDIR}/

# Get useful functions
cp ${DARTMNGDIR}/utils/functions.sh ${SCRATCHDIR}/
cp ${DARTMNGDIR}/utils/globus_tools.sh ${SCRATCHDIR}/
cp ${DARTMNGDIR}/utils/extensions.bc ${SCRATCHDIR}/

# Get scripts to be submitted with header corresponding to cluster
cd ${DARTMNGDIR}/src/
### FORWARD MODEL
# Also remove the dependency list and the mailing option for the forward script
sed "/<HEADER>/r header.${CLUSTER_PREP}" generic_roms_prepare_member.sub \
        | sed -e "/<HEADER>/d" \
              -e "/<DEPLIST>/d" \
              -e "/BSUB -N/d" \
              -e "/ptile=/d" \
              -e "s/select=<NNODES>:ncpus=36:mpiprocs=36/select=1:ncpus=1:mpiprocs=1/" \
              -e "/PBS -m/d" \
> ${SCRATCHDIR}/Jobfiles/${SIMU}_roms_prepare_member.sub 
sed "/<HEADER>/r header.${CLUSTER}" generic_roms_advance_member.sub \
        | sed -e "/<HEADER>/d" \
              -e "/BSUB -N/d" \
              -e "/PBS -m/d" \
> ${SCRATCHDIR}/Jobfiles/${SIMU}_roms_advance_member.sub 
sed "/<HEADER>/r header.${CLUSTER_PREP}" generic_roms_post_member.sub \
        | sed -e "/<HEADER>/d" \
              -e "/BSUB -N/d" \
              -e "/ptile=/d" \
              -e "s/select=<NNODES>:ncpus=36:mpiprocs=36/select=1:ncpus=1:mpiprocs=1/" \
              -e "/PBS -m/d" \
> ${SCRATCHDIR}/Jobfiles/${SIMU}_roms_post_member.sub
### ANALYSIS
sed "/<HEADER>/r header.${CLUSTER}" generic_analysis.sub \
        | sed -e "/<HEADER>/d" \
> ${SCRATCHDIR}/Jobfiles/${SIMU}_analysis.sub
### SUBMIT SCRIPT
# Also remove the mailing option for next submission script
sed "/<HEADER>/r header.${CLUSTER}" generic_submit_next.sub \
        | sed -e "/<HEADER>/d" \
              -e "/BSUB -N/d" \
              -e "s/select=<NNODES>:ncpus=36:mpiprocs=36/select=1:ncpus=1:mpiprocs=1/" \
              -e "/PBS -m/d" \
> ${SCRATCHDIR}/Jobfiles/${SIMU}_submit_next.sub
### STORING and POSTPROCESSING
cp roms2hpss.sub ${SCRATCHDIR}/Jobfiles/
cp Compute_spread_timeserie.sub ${SCRATCHDIR}/Jobfiles/

cd ${SCRATCHDIR}
echo "Creating working directory : $(pwd)"

# Launch 1rst iteration of cycle
#${SCRATCHDIR}/submit_cycle.sh $NSTART > ${SCRATCHDIR}/Logs/submit.log


