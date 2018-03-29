#!/bin/bash
#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Shell functions                                                                             #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

# List of functions


# Help!
# Example of use:
# > ls Logs/log_c01*.tar.gz > list_logs.txt
# > globus_transfer_ncar2poseidon list_logs.txt /glade/scratch/romaines/dart/tmpdir_NWA-RE.REANA49/Logs/ /Volumes/P15/DART/tmpdir_NWA-RE.REANA49/Logs/ "REANA49_Logs"

#---------------------------------------------------------------------------------------------#
# Create file for GLOBUS batch transfer

globus_create_transfer_file() { FILENAME=$1 ; SOURCE_PATH=$2 ; DEST_PATH=$3

   awk -F\\${SOURCE_PATH} -v prefix="$DEST_PATH"   '{print prefix$NF}' $FILENAME > $FILENAME.dest
   paste $FILENAME $FILENAME.dest > $FILENAME.transfer
   rm $FILENAME.dest

}



#---------------------------------------------------------------------------------------------#
# Transfer from GLADE to POSEIDON

globus_transfer_ncar2poseidon() { FILENAME=$1 ; SOURCE_PATH=$2 ; DEST_PATH=$3 ; LABEL=$4

   # Create batch file
   globus_create_transfer_file ${FILENAME} ${SOURCE_PATH} ${DEST_PATH}
   
   # Do the transfer
   cat ${FILENAME}.transfer | globus transfer --batch --preserve-mtime --label "$LABEL" $NCAR_ID $POSE_ID

}


#---------------------------------------------------------------------------------------------#
# Transfer from POSEIDON to GLADE

globus_transfer_poseidon2ncar() { FILENAME=$1 ; SOURCE_PATH=$2 ; DEST_PATH=$3 ; LABEL=$4

   # Create batch file
   globus_create_transfer_file ${FILENAME} ${SOURCE_PATH} ${DEST_PATH}

   # Do the transfer
   cat ${FILENAME}.transfer | globus transfer --batch --preserve-mtime --label "$LABEL" $POSE_ID $NCAR_ID

}


