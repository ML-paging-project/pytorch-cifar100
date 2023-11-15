#!/bin/bash

if [[ $# -ne 1 ]]; then
   echo "Require the number of models to train concurrently!"
   echo "Arguments: num_models"
   exit 1
fi

num_procs=$1

for (( i=0; i < num_procs; i++ ))
do
   taskset -c $((i + 0)),$((24+i)) python3 train.py -net resnet101 &
done
