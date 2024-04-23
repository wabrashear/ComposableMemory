#!/bin/bash

module purge
module load GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

env

for i in {50000,75000,100000,125000,150000}; do
	for j in {1}; do
		watch "/opt/memverge/bin/mvmcli show-usage >> mvmcli_$i.log" &> /dev/null &
		echo Dimension 1: $i Dimension2: $i
		echo Start time:
		date
		./mm -c ./mvmalloc_250.yml Rscript matrixMult_1.4.R --dim1 $i --dim2 $i
		echo End time:
		date
		killall -9 watch
		sleep 5
	done
done

killall -9 watch
