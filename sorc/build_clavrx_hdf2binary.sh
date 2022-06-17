#!/bin/sh
PWD=`pwd`;

set -ax 
set -ax 
module purge
moduledir=`dirname $(readlink -f ../modulefiles/NCO_INGEST)`
source ../versions/build.ver
module use ${moduledir}
module load NCO_INGEST/${nco_ingest_ver}
module list

export HDF4_INCLUDES=/apps/prod/hdf4/include
export HDF4_LIBRARIES=/apps/prod/hdf4/lib/

cd ${PWD}/clavrx_hdf2binary.cd
make clean
make 


