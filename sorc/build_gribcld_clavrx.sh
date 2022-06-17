#!/bin/sh
PWD=`pwd`;

set -ax 
module purge
moduledir=`dirname $(readlink -f ../modulefiles/NCO_INGEST)`
source ../versions/build.ver
module use ${moduledir}
module load NCO_INGEST/${nco_ingest_ver}
module list

cd ${PWD}/gribcld_clavrx.fd
make clean
make

