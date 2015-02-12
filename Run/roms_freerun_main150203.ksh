#!/bin/ksh

# NB: roms log output should be : log.roms_fwd.NNN
# NB: roms input.in should be   : ocean.in.NNN
# NB: roms hostfile should be   : hostfile.NNN


#-----------------------------------------------------------------------------------------------------
#
# functions 
#
#-----------------------------------------------------------------------------------------------------

# submit one member of the forward model
# model runs under each member directory
submit_fwd_run() { membr=$1 ; ncores_membr=$2 ;

   typeset -Z3 nnn
   nnn=${membr} 
   cp oceanM ./m${nnn}/
   cd ./m${nnn}/
   mpirun -hostfile ../hostfile.${nnn} -bind-to-core -np $ncores_membr \
          ../oceanM ocean_nwa.in.${nnn} > log.roms_fwd.${nnn} &
   sleep 1
   cd ../ ; } 
  
#------------------------------------------
# wait for all members of a group to finish
wait_end_fwd_runs() { firstmembr=$1 ; lastmembr=$2 ;

   typeset -Z3 nnn
   date
   echo ">>> Running forward model for assimilation window # $stp <<<"
   for membr_fwd in $(seq $firstmembr $lastmembr ) ; do
       nnn=${membr_fwd}
       echo "Member $nnn in $(tput setaf 1)progress$(tput sgr 0)..."
   done

   finished=false # init to false to enter while loop
   while [ $finished == false ] ; do
      finished=true # assume all runs are finished
      # clear       # output cosmetics
      for membr_fwd in $(seq $firstmembr $lastmembr ) ; do
          nnn=${membr_fwd}
          # check for each member if it has finished
          isdone=0
          isdone=$( grep DONE ./m${nnn}/log.roms_fwd.${nnn} | wc -l ) #1: true / 0: false
          isblowup=0
          isblowup=$( grep Blowing ./m${nnn}/log.roms_fwd.${nnn} | wc -l ) #1: true / 0: false
          # if at least one has not finished, set finished to false to stay in while loop
          if [ $isdone != 1 ] ; then 
             finished=false ; # echo "Member $nnn in $(tput setaf 1)progress$(tput sgr 0)..."
          elif [ $isdone = 1 -a  $isblowup = 1 ] ; then 
             echo "Member $nnn have $(tput setaf 1)blown up$(tput sgr 0)"
          #else
          #   echo "Member $nnn have $(tput setaf 2)finished$(tput sgr 0)"
          fi
      done
      sleep 10 # to be increased maybe
   done

   sleep 1
   # remove the ROMS log files - important !
   # rm log.roms_fwd.* ;
   for membr_fwd in $(seq $firstmembr $lastmembr ) ; do
       nnn=${membr_fwd}
       echo "Member $nnn have $(tput setaf 2)finished$(tput sgr 0)"
       mv ./m${nnn}/log.roms_fwd.${nnn}   ./m${nnn}/log.roms_fwd.${nnn}.old
   done  ;
}


#--------------------------------------------------------------
# prepare ocean_nwa.in files
prepare_ocean_in_files() { memb=$1 ; ntime=$2 ; itile=$3 ; jtile=$4 ;

    typeset -Z3 nnn
    nnn=${memb}
    initialfile=/t1/scratch/bjchoi/DART/Inputs/IC-NWA/m${nnn}/HYCOM_GLBa0.08_2010_356_ic_NWA.nc
    restartfile=/t1/scratch/bjchoi/DART/Run/m${nnn}/nwa_${nnn}_2010_rst.nc
    historifile=/t1/scratch/bjchoi/DART/Run/m${nnn}/nwa_${nnn}_2010_his.nc
    averagefile=/t1/scratch/bjchoi/DART/Run/m${nnn}/nwa_${nnn}_2010_avg.nc
    uwindfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Uwind_3hours_2010.nc
    uwindfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Uwind_3hours_2011.nc
    vwindfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Vwind_3hours_2010.nc
    vwindfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Vwind_3hours_2011.nc
    tairfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Tair_3hours_2010.nc
    tairfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Tair_3hours_2011.nc
    swradfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_swrad_3hours_2010.nc
    swradfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_swrad_3hours_2011.nc
    cat ocean_NWA.in_FreeRun_template | sed -e "s;<NTIME>;$ntime;g" \
                                       -e "s;<ITILE>;$itile;g" \
                                       -e "s;<JTILE>;$jtile;g" \
                                       -e "s;<INITIALFILE>;$initialfile;g" \
                                       -e "s;<RESTARTFILE>;$restartfile;g" \
                                       -e "s;<HISTORIFILE>;$historifile;g" \
                                       -e "s;<AVERAGEFILE>;$averagefile;g" \
                                       -e "s;<UWINDFILE2010>;$uwindfile2010;g" \
                                       -e "s;<UWINDFILE2011>;$uwindfile2011;g" \
                                       -e "s;<VWINDFILE2010>;$vwindfile2010;g" \
                                       -e "s;<VWINDFILE2011>;$vwindfile2011;g" \
                          -e "s;<TAIRFILE2010>;$tairfile2010;g" \
                          -e "s;<TAIRFILE2011>;$tairfile2011;g" \
                          -e "s;<SWRADFILE2010>;$swradfile2010;g" \
                          -e "s;<SWRADFILE2011>;$swradfile2011;g" > ./m${nnn}/ocean_nwa.in.${nnn} ;
}


#-----------------------------------------------------------------
#
# USER's specifications
#
# change 2 things
# (1) nsteps
#-----------------------------------------------------------------

  typeset -Z3 mmm

# ROMS model =============
# Number of cores used for one single member
# of the forward model 
   ncores_member=160
   ntilei=16   # cores
   ntilej=10   # nodes
# Total number of members 
   nmembers=30
# Number of Members Per execution Group (2-4)
   nmem_pg=2
# Number of execution Groups ( nmembers / nmem_pg )
   ngrp=15

# how many days do you want run ROMS freely before the data assimilation:
   stp_day=10     # days

#---Main Loop (time)---
#for stp in $(seq $isteps $nsteps ) ; do

    #--------- 1. Forward Model --------------
    # 1.1 Generate namelist (ocean.in) for Forward Model
    #     copy ocean.in file to each member directory  
    ntimes=$(( $stp_day * 480 ))
    for member_in in $( seq 1 $nmembers ) ; do
        prepare_ocean_in_files ${member_in} $ntimes $ntilei $ntilej
    done
    echo " ocean.in files were prepared for $nmembers members "
    sleep 1

    # 1.2 Run Forward Model

    for group in $( seq 1 $ngrp ) ; do

        fmem=$(( 1 + ( $group - 1 ) * $nmem_pg ))        #first member in grp
        lmem=$(( $nmem_pg + ( $group - 1 ) * $nmem_pg )) #last  member in grp

        echo "Submitting members $fmem to $lmem"

        for member in $(seq $fmem $lmem ) ; do
            # clean-up - important!
            # all ROMS log files should be removed before the start
            mmm=$member
            rm ./m${mmm}/log.roms_fwd.${mmm}
            sleep 1
            echo "Submitting member $member "
            submit_fwd_run $member $ncores_member &
        done
        sleep 1

        wait_end_fwd_runs $fmem $lmem
        sleep 2

    done
   
#done ;

