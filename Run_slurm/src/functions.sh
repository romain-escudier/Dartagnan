#!/bin/bash
#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Shell functions                                                                             #
#                                                                                             #
#---------------------------------------------------------------------------------------------#


nb_days_months=(31 28 31 30 31 30 31 31 30 31 30 31)


#---------------------------------------------------------------------------------------------#
# Compute sum of an array

get_sum_from_array() {

declare -i TOTAL=0
for vari in $*; do
  TOTAL=${TOTAL}+${vari}
done
echo ${TOTAL}

}


#---------------------------------------------------------------------------------------------#
# Compute date from cycle and start date

get_date_from_cycle() { CYCLE=$1 ; STARTDATE=$2 ; DTCYCLE=$3

   # Local variable
   declare -i ISTP_TMP=$(( ${CYCLE}*$DTCYCLE ))
   declare -i YEAR_START=${STARTDATE:0:4}
   declare -i YEAR_TMP=${YEAR_START}
   declare -i MONT_TMP=${STARTDATE:4:2}
   declare -i DAYS_TMP=${STARTDATE:6:2}
   
   #######################################################
   #           FIND WHICH YEAR FOR CYCLE
   #######################################################
   
   while ((${ISTP_TMP}>0))
   do
      declare -i NDAYS=365
      # check if it is a leap year
      IS_LEAP=$(is_leap_year ${YEAR_TMP})
      if [ "${IS_LEAP}" = true ] ; then
         NDAYS=366
      fi
   
      # Different if it is the first year (may not start on Jan 1st)
      if ((${YEAR_TMP} == ${YEAR_START})) ; then
         if ((${MONT_TMP}>3)) || [ "${IS_LEAP}" = false ]; then
            NDAYS=$(get_sum_from_array ${nb_days_months[*]:${MONT_TMP}-1})-${DAYS_TMP}+1
         else
            NDAYS=$(get_sum_from_array ${nb_days_months[*]:${MONT_TMP}-1})-${DAYS_TMP}+2
         fi
      fi
      ISTP_TMP=${ISTP_TMP}-${NDAYS}
      YEAR_TMP=YEAR_TMP+1
   done

   YEAR_TMP=YEAR_TMP-1
   if ((${YEAR_TMP} != ${YEAR_START})) ; then
      MONT_TMP=1
      DAYS_TMP=1
   fi
   ISTP_TMP=${ISTP_TMP}+${NDAYS}
    
   #######################################################
   #           FIND WHICH MONTH FOR CYCLE
   #######################################################
   
   while ((${ISTP_TMP}>0))
   do
      NDAYS=${nb_days_months[${MONT_TMP}-1]}
      if ((${MONT_TMP} == 2)) ; then
         if [ "${IS_LEAP}" = true ] ; then
            NDAYS=29
         fi
      fi
      ISTP_TMP=${ISTP_TMP}-${NDAYS}
      MONT_TMP=MONT_TMP+1
   done

   MONT_TMP=MONT_TMP-1
   declare -i DAYS_TMP=${ISTP_TMP}+${NDAYS}
   
   MONT_DISP=$( printf "%02d" ${MONT_TMP} )
   DAYS_DISP=$( printf "%02d" ${DAYS_TMP} )
   echo "${YEAR_TMP}${MONT_DISP}${DAYS_DISP}"

}

#---------------------------------------------------------------------------------------------#
# Compute difference in days between two dates

get_timediff_dates() { DATE1=$1 ; DATE2=$2

   declare -i YEAR1=${DATE1:0:4} MONT1=${DATE1:4:2} DAYS1=${DATE1:6:2}
   declare -i YEAR2=${DATE2:0:4} MONT2=${DATE2:4:2} DAYS2=${DATE2:6:2}

   declare -i NTIME=0

   #######################################################
   #           Loop on years
   #######################################################
   for YEAR_TMP in $( seq ${YEAR1} $((${YEAR2}-1)) ) ; do
      declare -i NDAYS=365
      # check if it is a leap year
      IS_LEAP=$(is_leap_year ${YEAR_TMP})

      if [ "${IS_LEAP}" = true ] ; then
         NDAYS=366
      fi
      NTIME=${NTIME}+${NDAYS}

   done

   #######################################################
   #           Remove year1 days
   #######################################################
   LEAP1=$(is_leap_year ${YEAR1})
   if [[ "${LEAP1}" = true && ((${MONT1} > 2)) ]] ; then
      NDAYS=$(get_sum_from_array ${nb_days_months[*]:0:$((${MONT1}-1))})+1
   else
      NDAYS=$(get_sum_from_array ${nb_days_months[*]:0:$((${MONT1}-1))})
   fi
   NDAYS=${NDAYS}+${DAYS1}
   NTIME=${NTIME}-NDAYS

   #######################################################
   #           Add year2 days
   #######################################################
   LEAP1=$(is_leap_year ${YEAR2})
   if [[ "${LEAP2}" = true && ((${MONT2} > 2)) ]] ; then
      NDAYS=$(get_sum_from_array ${nb_days_months[*]:0:$((${MONT2}-1))})+1
   else
      NDAYS=$(get_sum_from_array ${nb_days_months[*]:0:$((${MONT2}-1))})
   fi
   NDAYS=${NDAYS}+${DAYS2}
   NTIME=${NTIME}+NDAYS

   echo ${NTIME}
}



#---------------------------------------------------------------------------------------------#
# Determine is year is leap year

is_leap_year() { YEAR_TMP=$1

   IS_LEAP=false
   # check if it is a leap year
   declare -i B4=0
   declare -i B100=0
   declare -i B400=0
   B4=$((${YEAR_TMP}/4))
   B4=$(($B4*4))
   B100=$((${YEAR_TMP}/100))
   B100=$(($B100*100))
   B400=$((${YEAR_TMP}/400))
   B400=$(($B400*400))
   if ((${YEAR_TMP} == $B4 )) ; then
      if ((${YEAR_TMP} == $B100)) ; then
         if ((${YEAR_TMP} == $B400)) ; then
            IS_LEAP=true
         fi
      else
         IS_LEAP=true
      fi
   fi
   echo $IS_LEAP
}

#---------------------------------------------------------------------------------------------#
# Get parameter value from netCDF file

get_param_from_nc() { FILENAME=$1 ; VARNAME=$2

   VARVALUE=$(ncdump -v ${VARNAME} ${FILENAME}  | awk '{FS="data:"; RS="ceci1est8une9valeur5impossible"; print $2}');
   VARVALUE=${VARVALUE#*=}; VARVALUE=${VARVALUE%;*\}}
   
   echo ${VARVALUE}

}

#---------------------------------------------------------------------------------------------#
# Get dimension size from netCDF file

get_ndim_from_nc() { FILENAME=$1 ; DIMNAME=$2

   NDIM=$(ncdump -h /t0/scratch/romain/inputs/NWA_grd.nc | awk \
        '{FS="variables:"; RS="ceci1est8une9valeur5impossible"; print $1}' | grep ${DIMNAME})
   NDIM=${NDIM#*=}; NDIM=${NDIM%;*}
   echo ${NDIM}

}


print_time_dart() { MYDATE=$1

   MYYEAR=${MYDATE:0:4}
   MYMONTH=${MYDATE:4:2}
   MYDAY=${MYDATE:6:2}
   
   DATEOUT="${MYYEAR}-${MYMONTH}-${MYDAY} 00:00:00"
   
   echo ${DATEOUT}

}

print_time_dart_list() { MYDATE=$1

   MYYEAR=${MYDATE:0:4}
   MYMONTH=${MYDATE:4:2}
   MYDAY=${MYDATE:6:2}

   MYHR=${MYDATE:8:2}
   MYMN=${MYDATE:10:2}
   MYSC=${MYDATE:12:2}
   if [ -z $MYHR ] ; then
      DATEOUT="${MYYEAR}, ${MYMONTH}, ${MYDAY}, 0, 0, 0"
   else
      DATEOUT="${MYYEAR}, ${MYMONTH}, ${MYDAY}, ${MYHR}, ${MYMN}, ${MYSC}"
   fi

   echo ${DATEOUT}

}


compute_eq_integer_result() { EQUATION=$1

   res=$(echo "scale=0; $1" | bc -l)
   echo ${res%.*}

}








