#!/bin/bash

module purge
module load GCC/11.3.0 OpenMPI/4.1.4 R/4.2.1

env


for i in {100000,125000,150000,175000,200000,225000}; do
	for j in {1}; do
	    sudo swapoff -a
	    sleep 10
    	    sudo swapon -a	    
	    watch "cat /proc/meminfo >> meminfo_$i.log; date +"%Y-%m-%dT%H:%M:%S%z" >> meminfo_$i.log" &> /dev/null &
            watch "ps -p $(pgrep -f "matrixMult_1.4.R") -o %cpu,%mem,cmd --no-headers >> ps_output_$i.log; date +'%Y-%m-%dT%H:%M:%S%z' >> ps_output_$i.log" &> /dev/null &
            watch "free -h >> free_output_$i.log;  date +'%Y-%m-%dT%H:%M:%S%z' >> free_output_$i.log" &> /dev/null &
		echo Dimension 1: $i Dimension2: $i
		echo Start time:
		date
		Rscript matrixMult_1.4.R --dim1 $i --dim2 $i
		echo End time:
		date
		killall -9 watch
		sleep 5
	done
done

killall -9 watch
