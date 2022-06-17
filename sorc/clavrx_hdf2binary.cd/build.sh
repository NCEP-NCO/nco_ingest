#!/bin/sh
PWD=`pwd`;
set -eua

export machine=wcoss
export CC=icc

export CFLAGSM="-O3"
export LDFLAGSM=

module purge
module load ips/18.0.1.163 
module load impi/18.0.1
module load jasper/1.900.29
module load libpng/1.2.59
module load zlib/1.2.11
module load HDF5-serial/1.10.1
module list

cd $PWD/clavrx_hdf2binary.cd
pwd
make -f Makefile clean
make -f Makefile
#make -f Makefile; mv $execs ../../exec
#make -f Makefile clean

