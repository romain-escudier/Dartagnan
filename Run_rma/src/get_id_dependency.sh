#!/bin/bash

OUTPUTS=$1
LISTJOB=$2
CLUSTER=$3

if [ ${CLUSTER} = "triton" ] || [ ${CLUSTER} = "cheyenne" ] ; then
   id=$( echo $OUTPUTS | awk '{ print $NF }' )
   LISTJOB="$LISTJOB:$id"
elif [ ${CLUSTER} = "yellowstone" ] ; then
   id=$( echo $OUTPUTS | awk '{ print $2 }' | awk -F "[<>]" '{print $2}')
   if  [ -z $LISTJOB ] ; then
      LISTJOB="done($id)"
   else
      LISTJOB="$LISTJOB\&\&done($id)"
   fi
else
   echo "Error. The cluster $CLUSTER is not recognized. Check if it has been setup in the get_id_dependency.sh script."
   exit 1
fi

echo $LISTJOB



