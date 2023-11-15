#!/bin/bash

if [[ $# -ne 2 ]]; then
   echo "Incorrect number of arguments. Require 2"
   echo "Arguments: output_directory num_models"
   exit 1
fi

output_dir=$1
num_procs=$2

pids=()

mkdir result 2> /dev/null
mkdir $output_dir 2> /dev/null


perf stat -B -C 0-$((num_procs-1)) -e cache-references,cache-misses -o result/cache_stats.txt & 
./metrics.sh result/cpu_stats.txt 1 $num_procs &

# perf here

for (( i=0; i < num_procs; i++ ))
do
   taskset -c $i,$((i + 24)) python3 train.py -net vgg11 &
   ./mem_record.sh $!   &
done

while true; do
   lines=`ls -l result | wc -l`
   if [[ lines -ge $((num_procs * 2 + 3)) ]]; then
      echo "All processes have finished first epoch... Exiting!"
      break
   fi
   sleep 5
done

# Kill all child processes
sleep 3
pkill -P -2 $$
sleep 1
pkill -P $$

# Move results
sleep 3
mv result/* $output_dir/
rmdir result

# Print the results we got
echo "Experiment Results -> $output_dir"
cat $output_dir/*
