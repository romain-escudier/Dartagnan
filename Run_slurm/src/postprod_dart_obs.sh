#!/bin/bash

. ./parameters
. ./functions.sh

#------------------------------------------------------------------------------------
# Load the appropriate modules (from module-used)
#------------------------------------------------------------------------------------

sed '1d' ${SCRATCHDIR}/modules-used > ${SCRATCHDIR}/Tempfiles/modules.dat
list=$( cat ${SCRATCHDIR}/Tempfiles/modules.dat | sed -e "s/[0-9])//g" )
module purge
for mod in $list ; do
   module load $mod
done
rm ${SCRATCHDIR}/Tempfiles/modules.dat

#------------------------------------------------------------------------------------
# Post production process
#------------------------------------------------------------------------------------

# Observation assimilated directory
obs_dir=${SCRATCHDIR}/Outputs/ObsOut/

# Maximum number of bins
max_bins=1000

# Create a list with all the final observation files
LIST_FILES=${SCRATCHDIR}/Tempfiles/list_obs.txt
find ${obs_dir} -type f > ${LIST_FILES}

return 1

# Dates of bins
date_first_bin_start=${STARTDATE}
date_first_bin_end=$(get_date_from_cycle 2 ${STARTDATE} ${DT_ANA})
date_last_bin=$(get_date_from_cycle $((${NCYCLES} +1)) ${STARTDATE} ${DT_ANA})

# Fill the DART namelist 
cat ${SCRATCHDIR}/input_${SIMU}.nml  | sed -e "s;<OBS_SEQ_LIST>;${LIST_FILES};g" \
                                           -e "s;<DATESTARTBIN>;$(print_time_dart_list ${date_first_bin_start}120000);g" \
                                           -e "s;<DATEENDBIN>;$(print_time_dart_list ${date_last_bin}120000);g" \
                                           -e "s;<BINSEP>;$(print_time_dart_list 00000001);g" \
                                           -e "s;<BINWIDTH>;$(print_time_dart_list 00000001);g" \
                                           -e "s;<MAXBINS>;${max_bins};g" \
                                           -e "s;<DATESTARTBIN_INI>;$(print_time_dart_list ${date_first_bin_start});g" \
                                           -e "s;<DATESTARTBIN_END>;$(print_time_dart_list ${date_first_bin_end});g" \
                                           -e "s;<DATEENDBIN_END>;$(print_time_dart_list ${date_last_bin});g" \
                                           -e "s;<DARTLOGOUT>;${SCRATCHDIR}/Logs/DART/dart_post.out;g" \
                                           -e "s;<DARTLOGNML>;${SCRATCHDIR}/Logs/DART/dart_post.nml;g" \
                                           -e "s;<DTANA>;${DT_ANA};g" \
                                           -e "s;<;;g" \
                                           -e "s;>;;g" \
> ${SCRATCHDIR}/input.nml

cd ${SCRATCHDIR}

# Create diagnostic file
${SCRATCHDIR}/Exe/obs_diag > ${SCRATCHDIR}/Logs/DART/dart_diags.log
mv obs_diag_output.nc ${SCRATCHDIR}/Outputs/Diags/
mv LargeInnov.txt ${SCRATCHDIR}/Outputs/Diags/

# Create netcdf observation files
${SCRATCHDIR}/Exe/obs_seq_to_netcdf > ${SCRATCHDIR}/Logs/DART/dart_obsfiles.log
mv obs_epoch_*.nc ${SCRATCHDIR}/Outputs/Diags/
rename obs_epoch_ ${OBS_PREF} ${SCRATCHDIR}/Outputs/Diags/obs_epoch*.nc


