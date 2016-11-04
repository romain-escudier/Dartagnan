#!/bin/bash

#---------------------------------------------------------------------------------------------#
#                                                                                             #
# Clean the scratch                                                                           #
#                                                                                             #
#---------------------------------------------------------------------------------------------#

. ./parameters

echo "Clean the directory : ${SCRATCHDIR}"
# Clean scratch directory
rm -f ${SCRATCHDIR}/*
rm -r ${SCRATCHDIR}/Outputs/*
rm -r ${SCRATCHDIR}/Roms_files/*
rm -r ${SCRATCHDIR}/Tempfiles/*
rm -f ${SCRATCHDIR}/Logs/*
rm -f ${SCRATCHDIR}/Logs/DART/*
rm -f ${SCRATCHDIR}/Logs/ROMS/*

