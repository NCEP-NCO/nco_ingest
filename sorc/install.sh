#!/bin/shset -x -e
EXECdir=../exec
[ -d $EXECdir ] || mkdir $EXECdir
for dir in *.?d; do
 cd $dir
 pwd
 make install
 cd ..
done

