#!/bin/ksh
#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Cycle                                                                                       #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

if [ ! $# == 1 ] ; then echo 'this script needs the cycle number as an argument' ; exit 1 ; fi

cycle=$1

. ./parameters
. ./functions.ksh   

echo running cycle $cycle of $ncycles

if [[ $cycle > $ncycles ]] ; then echo 'Completed' ; exit 0 ; fi

#---------------------------------------------------------------------------------------------#
# 1. submit ensemble members

listjobids=""

for kmem in $( seq 1 $nmembers ) ; do

    cat generic_roms_advance_member.sub | sed -e "s/<MEMBER>/$kmem/g" \
                                              -e "s;<CDIR>;$CONTROLDIR;g" \
    > roms_advance_member_${kmem}.sub

    output=$( sbatch < roms_advance_member_${kmem}.sub )
    id=$( echo $output | awk '{ print $NF }' )
    listjobids="$listjobids:$id"

done

#---------------------------------------------------------------------------------------------#
# 2. submit assimilation step

cat generic_analysis.sub | sed -e "s/<DEPLIST>/$listjobids/g" \
                               -e "s/<CYCLE>/$cycle/g" \
                               -e "s;<CDIR>;$CONTROLDIR;g" \
> analysis.sub

sbatch < analysis.sub
