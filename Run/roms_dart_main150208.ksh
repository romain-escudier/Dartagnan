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
   #cp oceanM ./m${nnn}/
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

#--------------------------------------------------
# check if any model simulation blew up before the filter
# and replace restart file with 3 day before his file
check_if_any_blew_up_model_1() {

    typeset -Z3 nnn
    typeset -Z5 sssss ttttt uuuuu
    nmember=30
    FWDDIR='/t1/scratch/bjchoi/DART/nwaForward/'
    RUNDIR='/t1/scratch/bjchoi/DART/Run/'
    read  istep < roms_dart_log.istep
    pre3step=$(($istep-3 +10))
    aft1step=$(($istep+1 +10))   # On this step, his file was damaged by data assimilation.
    aft2step=$(($istep+2 +10))   # On this step, his file was created but variables were not stored.
    sssss=$pre3step
    ttttt=$aft1step
    uuuuu=$aft2step
    # echo $sssss

    # check if each ensemble member did not blow up
    isblowup=0
    isblowup=$( grep Blowing ./m*/log.roms_fwd.*.old | wc -l ) 
    if [ $isblowup -gt 0 ]; then
       grep  Blowing ./m*/log.roms_fwd.*.old
       echo " We have $isblowup $(tput setaf 1)BLOWN UP MODELS!$(tput sgr 0)"
       for imem in $( seq 1 $nmember); do
           nnn=$imem
           isblowup=0
           isblowup=$( grep  Blowing ./m${nnn}/log.roms_fwd.${nnn}.old | wc -l ) #1: true / 0: false  
           if [ $isblowup = 1 ]; then
              cp ${FWDDIR}nwa_${nnn}_2011_his_${sssss}.nc ${RUNDIR}${nnn}/nwa_${nnn}_2011_rst.nc
              cp ${FWDDIR}nwa_${nnn}_2011_his_${sssss}.nc ${FWDDIR}nwa_${nnn}_2011_his_${ttttt}.nc
              cp ${FWDDIR}nwa_${nnn}_2011_his_${sssss}.nc ${FWDDIR}nwa_${nnn}_2011_his_${uuuuu}.nc
              echo " restart file for member = $nnn was copied from history file 4 days ago. "
              echo " It will run for 5 days without data assimilation "
              echo " This is a temporary remedy for a model member blown up.  " 
           fi
       done
       # exit
    fi
}

#--------------------------------------------------
# check if any model simulation blew up after the filter
# and replace restart file with 3 day before his file
check_if_any_blew_up_model_2() {

    typeset -Z3 nnn
    typeset -Z5 sssss
    nmember=30
    FWDDIR='/t1/scratch/bjchoi/DART/nwaForward/'
    RSTDIR='/t1/scratch/bjchoi/DART/nwaReanaly/'
    read  istep < roms_dart_log.istep
    pre3step=$(($istep-3 +10))
    sssss=$pre3step

    # check if each ensemble member did not blow up
    isblowup=0
    isblowup=$( grep  Blowing ./m*/log.roms_fwd.*.old | wc -l ) #more than 1: true / 0: false
    if [ $isblowup -gt 0 ]; then
       grep  Blowing ./m*/log.roms_fwd.*.old
       echo " We have $isblowup $(tput setaf 1)BLOWN UP MODELS!$(tput sgr 0)"
       for imem in $( seq 1 $nmember); do
           nnn=$imem
           isblowup=0
           isblowup=$( grep  Blowing ./m${nnn}/log.roms_fwd.${nnn}.old | wc -l ) #1: true / 0: false  
           if [ $isblowup = 1 ]; then
              cp ${FWDDIR}nwa_${nnn}_2011_his_${sssss}.nc ${RSTDIR}nwa_${nnn}_2011_rst.nc
              echo " restart file for member = $nnn was copied from history file 4 days ago. "
              echo " It will run for 5 days without data assimilation "
              echo " This is a temporary remedy for a model member blown up.  " 
           fi
       done
       # exit
    fi
}

#--------------------------------------------------
# move average files to a separate directory 
move_average_files() {

    typeset -Z3 nnn
    typeset -Z5 sssss
    typeset -Z5 hhhhh
    nmember=30
    FWDDIR='/t1/scratch/bjchoi/DART/nwaForward/'
    AVGDIR='/t4/workdir/bjchoi/DART/nwaForward01/'
    read  istep < roms_dart_log.istep
    current_step_a=$(($istep +10))
    current_step_h=$(($istep+1 +10))
    sssss=$current_step_a
    hhhhh=$current_step_h

    # check if each ensemble member did not blow up
    if [ $isblowup -gt 0 ]; then
       for imem in $( seq 1 $nmember); do
           nnn=$imem
           isblowup=0
           isblowup=$( grep  Blowing ./m${nnn}/log.roms_fwd.${nnn}.old | wc -l ) #1: true / 0: false  
           if [ $isblowup != 1 ]; then
              # cp ${FWDDIR}nwa_${nnn}_2011_his_${hhhhh}.nc ${AVGDIR}m${nnn}/
              # mv ${FWDDIR}nwa_${nnn}_2011_avg_${sssss}.nc ${AVGDIR}m${nnn}/
              nice -10 rsync -av ${FWDDIR}nwa_${nnn}_2011_his_${hhhhh}.nc ${AVGDIR}m${nnn}/
              nice -10 rsync -av ${FWDDIR}nwa_${nnn}_2011_avg_${sssss}.nc ${AVGDIR}m${nnn}/
              rm                 ${FWDDIR}nwa_${nnn}_2011_avg_${sssss}.nc 
           fi
       done
    fi

}

#--------------------------------------------------------------
# prepare ocean_nwa.in files
prepare_ocean_in_files() { memb=$1 ; ntime=$2 ; itile=$3 ; jtile=$4 ;

    typeset -Z3 nnn
    nnn=${memb}
    initialfile=/t1/scratch/bjchoi/DART/nwaReanaly/nwa_${nnn}_2011_rst.nc
    restartfile=/t1/scratch/bjchoi/DART/Run/m${nnn}/nwa_${nnn}_2011_rst.nc
    historifile=/t1/scratch/bjchoi/DART/nwaForward/nwa_${nnn}_2011_his.nc
    averagefile=/t1/scratch/bjchoi/DART/nwaForward/nwa_${nnn}_2011_avg.nc
    uwindfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Uwind_3hours_2010.nc
    uwindfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Uwind_3hours_2011.nc
    vwindfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Vwind_3hours_2010.nc
    vwindfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Vwind_3hours_2011.nc
    tairfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Tair_3hours_2010.nc
    tairfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_Tair_3hours_2011.nc
    swradfile2010=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_swrad_3hours_2010.nc
    swradfile2011=/t1/scratch/bjchoi/DART/Inputs/Force/m${nnn}/drowned_MERRA_swrad_3hours_2011.nc
    cat ocean_NWA.in_DA_template | sed -e "s;<NTIME>;$ntime;g" \
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


#--------------------------------------------------
# roms to dart 
multifile_roms_to_dart() { nmember_r2d=$1 ;

typeset -Z3 nnn    # ROMS uses 3 digit file number
typeset -Z4 nnnn   # DART uses 4 digit file number

echo "> Converting ROMS nc files to DART binary files <"
for nm in $( seq 1 ${nmember_r2d} ) ; do
    nnn=$nm
    nnnn=$nm
    roms_restart=/t1/scratch/bjchoi/DART/Run/m${nnn}/nwa_${nnn}_2011_rst.nc
    dart_output=/t1/scratch/bjchoi/DART/nwaDartTMP/dart.ics.${nnnn}
    grid_file=/t1/scratch/bjchoi/DART/Inputs/Grid/NWA_grd.nc
    analysistime=$( ncdump -v ocean_time $roms_restart | tail -2 | head -1 | awk '{print $4}' )
    echo $roms_restart $dart_output $analysistime 

    cat input.nml.template.r2d | sed -e "s;<MODEL_RESTART_FILENAME>;$roms_restart;g" \
                                     -e "s;<DART_OUTPUT_FILENAME>;$dart_output;g" \
                                     -e "s;<GRID_FILENAME>;$grid_file;g" > input.nml.tmp.r2d
    cp input.nml.tmp.r2d input.nml
    # run a Fortran program
    ./roms_to_dart
    # $roms_restart Please do not remove restart files
done ; }

#----------------------------------------------
# dart to roms
multifile_dart_to_roms() { nmember_d2r=$1 ;

typeset -Z3 nnn    # ROMS uses 3 digit file number
typeset -Z4 nnnn   # DART uses 4 digit file number

echo "> Converting  DART binary files to ROMS nc files <"
for nm in $( seq 1 ${nmember_d2r} ) ; do
    nnn=$nm
    nnnn=$nm
    roms_restart=/t1/scratch/bjchoi/DART/Run/m${nnn}/nwa_${nnn}_2011_rst.nc
    roms_reanaly=/t1/scratch/bjchoi/DART/nwaReanaly/nwa_${nnn}_2011_rst.nc
    dart_output=/t1/scratch/bjchoi/DART/nwaDartTMP/dart.restart.${nnnn}
    grid_file=/t1/scratch/bjchoi/DART/Inputs/Grid/NWA_grd.nc
    analysistime=$( ncdump -v ocean_time $roms_restart | tail -2 | head -1 | awk '{print $4}' )
    echo $roms_restart $dart_output $analysistime 

    cp $roms_restart  $roms_reanaly
    cat input.nml.template.d2r | sed -e "s;<MODEL_RESTART_FILENAME>;$roms_reanaly;g" \
                                     -e "s;<DART_OUTPUT_FILENAME>;$dart_output;g" \
                                     -e "s;<GRID_FILENAME>;$grid_file;g" > input.nml.tmp.d2r
    cp input.nml.tmp.d2r input.nml
    # run a Fortran program
    ./dart_to_roms
    # mv $dart_output ${dart_output}.old
done ; }

#-----------------------------------------------------------------
# run filter
run_filter() { nmember_filter=$1 ; fyear=$2 ; fmonth=$3 ; fday=$4 ; fstep=$5 ;

    typeset -Z4 yyyy
    typeset -Z2 mm 
    typeset -Z2 dd

    echo "> Running Ensemble Kalman Filter ... now <"
    yyyy=$fyear
    mm=$fmonth
    dd=$fday
    day_zero=149748
    jday=$(( day_zero + $fstep )) # jday = cumulative days from 1601.01.01
    obs_seq_in=/t1/scratch/bjchoi/DART/ObsData/MERGEDobsSEQ/obs_seq.sst1_gtspp$yyyy$mm$dd
    obs_seq_out=/t1/scratch/bjchoi/DART/nwaDartTMP/obs_seq.final$yyyy$mm$dd
    restart_in=/t1/scratch/bjchoi/DART/nwaDartTMP/dart.ics
    restart_out=/t1/scratch/bjchoi/DART/nwaDartTMP/dart.restart
    roms_restart_file=/t1/scratch/bjchoi/DART/Run/m002/nwa_002_2011_rst.nc  #read grid info
    grid_file=/t1/scratch/bjchoi/DART/Inputs/Grid/NWA_grd.nc
   
    cat input.nml.template.filter | sed -e "s;<NMEMBER>;$nmember_filter;g" \
                                        -e "s;<OBS_SEQ_IN_FILE>;$obs_seq_in;g" \
                                        -e "s;<OBS_SEQ_OUT_FILE>;$obs_seq_out;g" \
                                        -e "s;<RESTART_IN_FILE>;$restart_in;g" \
                                        -e "s;<RESTART_OUT_FILE>;$restart_out;g" \
                                        -e "s;<ASSIM_DAY>;$jday;g" \
                                        -e "s;<FIRST_OBS_DAY>;$(($jday-3));g" \
                                        -e "s;<LAST_OBS_DAY>;$(($jday+3));g" \
                                        -e "s;<ROMS_RESTART_FILENAME>;$roms_restart_file;g" \
                                        -e "s;<GRID_FILENAME>;$grid_file;g" > input.nml.tmp.filter

    cp input.nml.tmp.filter input.nml
 
    echo "running with no queueing system"
    NUM_PROCS=`cat nodelist-gfortran | wc -l`
    NUM_CORES=$(( $NUM_PROCS * 16 ))
    MPIRUN=/usr/mpi/gcc/openmpi-1.4.3/bin/mpirun
    MPICMD=` echo ${MPIRUN} -hostfile nodelist-gfortran -bind-to-core -np ${NUM_CORES} `
    echo "MPICMD = ${MPICMD}"

    # this starts filter but also returns control back to
    # this script immediately.
    ${MPICMD} ./filter 

    # remove initial DART state vector
    # typeset -Z4 nnnn
    # for nm in $( seq 1 ${nmember_filter} ) ; do 
    #    nnnn=$nm
    #    mv $restart_in.${nnnn} $restart_in.${nnnn}.old     
    #done ; 

    }

#-----------------------------------------------------------------
#
# USER's specifications
#
# change 2 things
# (1) nsteps
# (2) pre_step
#-----------------------------------------------------------------
  typeset -Z4 nnnn    
  typeset -Z3 mmm

# ROMS model =============
# Number of cores used for one single member
# of the forward model 
  ncores_member=160
  ntilei=16
  ntilej=10
# Total number of members 
  nmembers=30
# Number of Members Per execution Group (2-4)
  nmem_pg=2
# Number of execution Groups ( nmembers / nmem_pg )
  ngrp=15

# DART assimilaion =======
#  step is calculaed from 2011.01.01
# (step is 1 for 2011.01.01)
# Number of analysis step from 2011 January 01: 
  nsteps=365

#-----------------------------------------------------------------
# Initialization, these will be changed in the main for loop
  year=2011
  month=1
  day=1            # <--- write the day of initial (restart) files, 
                   #      ocean_time is the end of this day
  pre_step=0       # <--- Previous step or the day of the initial file

read pre_step < roms_dart_log.istep   # <--- initial value is zero
isteps=$(( $pre_step + 1 ))  #initial step (the first day we want to analyze)
#---Main Loop (time)---
for stp in $(seq $isteps $nsteps ) ; do

    # convert stp to year month day
    cat istep_to_ymd.nml.template | sed -e "s;<ISTEP>;$stp;g" >  istep_to_ymd.nml
    ./istep_to_ymd
    read year month day < istep_to_ymd.out   
    echo 'Working on year month day: ' $year $month $day

    # clean-up - important!
    # all ROMS log files should be removed before the start
    # rm UPW-RD*nc log.*
    for member in $(seq 1  $nmembers ) ; do
      mmm=$member
      rm ./m${mmm}/log.roms_fwd.${mmm}
    done

    #--------- 1. Forward Model --------------
    # 1.1 Generate namelist (ocean.in) for Forward Model

    ntimes=$(( $stp * 480 + 4800))
    for member_in in $( seq 1 $nmembers ) ; do
        prepare_ocean_in_files ${member_in} $ntimes $ntilei $ntilej
    done
    echo " ocean.in files are prepared for $nmembers members "
    sleep 1

    # 1.2 Run Forward Model

    for group in $( seq 1 $ngrp ) ; do

        fmem=$(( 1 + ( $group - 1 ) * $nmem_pg ))        #first member in grp
        lmem=$(( $nmem_pg + ( $group - 1 ) * $nmem_pg )) #last  member in grp
        echo "Submitting members $fmem to $lmem"

        for member in $(seq $fmem $lmem ) ; do
            echo "Submitting member $member "
            sleep 1
            submit_fwd_run $member $ncores_member &
        done
        sleep 1

        wait_end_fwd_runs $fmem $lmem
        sleep 2

    done
   
    sleep 1                                              #give time to close files

    # check if each ensemble member did not blow up
    # check if any model simulation blew up
    check_if_any_blew_up_model_1


    #--------- 2. Analysis Step --------------

    clear
    echo 'ASSIMILATION TIME...'
    sleep 1

    # 2.1 convert ROMS nc restart files to DART binary files
    multifile_roms_to_dart $nmembers  
   
    # 2.2 Perform Analysis
    # Generate namelist for DART and run_filter 
    run_filter $nmembers $year $month $day $stp

    # 2.3 convert DART binary files to ROMS nc restart files
    multifile_dart_to_roms $nmembers
 
    sleep 1
    # check if each ensemble member did not blow up
    # check if any model simulation blew up
    check_if_any_blew_up_model_2
    move_average_files

    sleep 1
    nnnn=$stp
    mv dart_log.out dart_log.out.${nnnn}
    echo $stp > roms_dart_log.istep

done ;

