####  UNIX Script Documentation Block
#
# Script name: ingest_clavr.sh
#
# JIF contact:  O'Reilly        org: NP11         date: 2007-03-05
#
# Abstract:   NESDIS 0.5 degree global gridded data file
#             'HDF' format:
#              1. extract a 15-record subset of the complete
#                 cloud file and create a binary file from the
#                 'HDF' formatted file.  All done in the "C"code
#                 step (written by NESDIS colleagues).
#              2. extract date from CLAVR cloud file and create
#                 a yyyymmddhh label to be appended to the
#                 file name.  Grid is 'flipped' so j=1 is near
#                 north (NESDIS=south) pole.  Create grib-1 file
#                 for archival purposes.
#
# Script history log:
# 2007-03-05  Patrick O'Reilly  original version for implementation created
#				from scripts and codes provided and
#				previously maintained by Ken Campana (EMC).
#
# Usage: ingest_clavr.sh $1 $2
#
#   Script parameters: $1 - full path definition for BUFR mnemonic table
#                      $2 - full path definition for clavrx_[0|1]* file
#
#   Modules and files referenced:
#     scripts     : None
#     executables : $pgm (clavrx_hdf2binary, gribcld_clavrx)
#
# Remarks:
#
#   Invoked by the script ingest_translate_orbits.
#
#   Imported Variables that must be passed in:
#      DATA     - path to current working directory
#      EXECbufr - path to executables
#      TANKDIR  - path to output IEEE and BUFR tank (e.g., /dcom/us007003)
#      TANKFILE - the name of the tank file to be created/appended.
#
#   Condition codes:
#     0     - no problem encountered
#     > 0 - some problem encountered
#       Specifically: exit 90 - Program clavrx_hdf2binary failure
#		      exit 91 - Program gribcld_clavrx failure
#
# Attributes:
#
#   Language: /bin/sh script
#   Machine:  IBM SP
#
#   2012-11-28 Simon Hsiao - Transition from CCS P6 to WCOSS TIDE
#
####

set -x

cd $DATA

#--------------------------------------------
# run 'C' executable to convert .hdf to .bin

pgm=clavrx_hdf2binary
export pgm
cwd=`pwd`
cd $DATA
. prep_step
cd $cwd

cp $TABLEDIR/clavrx_hdf2binary_input clavrx_hdf2binary_input

mv $2 clvrxFILE.hdf

$EXECbufr/clavrx_hdf2binary clvrxFILE.hdf
err=$?

if [ $err -eq 0 ]; then
echo " --------------------------------------------- "
echo " ********** COMPLETED PROGRAM   $pgm **********"
echo " --------------------------------------------- "
                  msg="PROGRAM $pgm completed normally"
                  postmsg "$jlogfile" "$msg"

else

echo "*******************************************************"
echo "********  ERROR PROGRAM $pgm  RETURN CODE $err ********"
echo "*******************************************************"
                  msg="ERROR PROGRAM $pgm RETURN CODE $err"
                  postmsg "$jlogfile" "$msg"
                  exit 90
fi

pgm=gribcld_clavrx
export pgm
cwd=`pwd`
cd $DATA
. prep_step
cd $cwd

# Alert the ibm that I will be assigning Fortran units
export XLFRTEOPTS="unit_vars=yes"

export FORT10="clvrxFILE.bin"
export FORT60="date.grib"
export FORT70="clvrxgrb"
export FORT_CONVERT10=LITTLE_ENDIAN  ## Due to clvrxFILE.bin is little-endian format created by /nwprod/exec/clavrx_hdfbinary
$EXECbufr/gribcld_clavrx
err=$?
unset FORT_CONVERT10

if [ $err -eq 0 ]; then
echo " --------------------------------------------- "
echo " ********** COMPLETED PROGRAM   $pgm **********"
echo " --------------------------------------------- "
                  msg="PROGRAM $pgm completed normally"
                  postmsg "$jlogfile" "$msg"

else

echo "*******************************************************"
echo "********  ERROR PROGRAM $pgm  RETURN CODE $err ********"
echo "*******************************************************"
                  msg="ERROR PROGRAM $pgm RETURN CODE $err"
                  postmsg "$jlogfile" "$msg"
                  exit 91
fi

grep yyyymmddhh date.grib | awk '{print $2}'
fdate=`grep yyyymmddhh date.grib | awk '{print $2}'`
echo "Filedate is: $fdate."
filedate=`echo $fdate | cut -c 1-8`

if [ ! -d $TANKDIR/$filedate/$TANKFILE/clavrx ] ; then
  mkdir -p $TANKDIR/$filedate/$TANKFILE/clavrx
fi

if [ $SENDCOM = "YES" ] ; then
   cp clvrxgrb $TANKDIR/$filedate/$TANKFILE/clavrx/clvrxgrb.${fdate}
fi

exit 0
