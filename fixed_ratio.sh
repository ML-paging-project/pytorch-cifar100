
memory=3000

function fixed_ratio() {
  procs=$1

  echo $((memory * procs))M > /sys/fs/cgroup/memory/Custom_Limit/memory.limit_in_bytes
  echo $((memory * procs))M > /sys/fs/cgroup/memory/Custom_Limit/memory.soft_limit_in_bytes
  cgexec -g memory:Custom_Limit ./parallel.sh fixed-ratio-$memory-$procs $procs
}

# fixed_ratio 1
fixed_ratio 2
# fixed_ratio 4
# fixed_ratio 8
# fixed_ratio 16
