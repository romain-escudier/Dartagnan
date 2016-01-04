#!/bin/ksh
#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Shell functions                                                                             #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

# Create the list of slurm jobids of members that analysis job depends on
# takes as arguments number of members and files with stdout redirection
create_dependency_list() { nmem=$1 ; filejobs=$2

  dep_list=''
  for kmem in $( seq 1 $nmem ) ; do
      jobid=$( sed -n ${kmem}p $filejobs | awk '{print $4}' )
      dep_list="${dep_list},$jobid"
  done
  dep_list=$( echo $dep_list | sed -e "s/,//" )
  echo $dep_list ; }
   

#---------------------------------------------------------------------------------------------#
#                                                                                             #
# PARAMETERS                                                                                  #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

nmembers=30

typeset -Z4 kkkk

#---------------------------------------------------------------------------------------------#
#                                                                                             #
# MAIN                                                                                        #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------------#
# 1. Delete previous list of jobs and Submit MPP job for each member
if [ -f jobids.list ] ; then rm jobids.list ; fi

for kmem in $( seq 1 $nmembers ) ; do

    cat generic_roms_advance_member.sub | sed -e "s/<MEMBER>/$kmem/g" \
    > roms_advance_member_${kmem}.sub

    sbatch roms_advance_member_${kmem}.sub >> jobids.list

done

#---------------------------------------------------------------------------------------------#
# 2. Create the dependency list and submit the analysis step as dependant
dep_list=$( create_dependency_list $nmembers jobids.list )

cat generic_analysis.sub | sed -e "s/<DEPLIST>/$dep_list/g" \
> analysis.sub

sbatch analysis.sub
