set -u

min_temp=1000000
avg_temp=0
max_temp=0

min_freq=1000000
avg_freq=0
max_freq=0

samples=0

# $1 = max cpu ID (non-inclusive of max)
average_freq() {
  max_cpu=$1
  freqs=$(cat /proc/cpuinfo | grep 'cpu MHz')
  total=0
  num=0
  while IFS= read -r line; do
    temp=${line##*:}
    freq=${temp%%.*}
    num=$((num+1))
    total=$((total+freq))

    if [[ $num -ge $max_cpu ]]; then
      break
    fi
  done <<< $freqs

  echo $((total / num))
}

# $1 = file
# $2 = cpu_temp
# $3 = freq
record_statistics() {
  avg_temp=$(((avg_temp * samples + $2) / (samples + 1)))
  avg_freq=$(((avg_freq * samples + $3) / (samples + 1)))
  samples=$((samples + 1))

  if [[ $2 -lt $min_temp ]]; then
    min_temp=$2
  fi
  if [[ $2 -gt $max_temp ]]; then
    max_temp=$2
  fi

  if [[ $3 -lt $min_freq ]]; then
    min_freq=$3
  fi
  if [[ $3 -gt $max_freq ]]; then
    max_freq=$3
  fi

  echo "CPU Temperature:" > $file
  echo "  cur=$2 min=$min_temp max=$max_temp avg=$avg_temp" >> $file
  echo "CPU frequency:" >> $file
  echo "  cur=$3 min=$min_freq max=$max_freq avg=$avg_freq" >> $file
}

if [[ $# -ne 3 ]]; then
  echo "ERROR: Incorrect number of arguments!"
  echo "USAGE: Record CPU temperature and frequency statistics to 'file' every"
  echo "       'interval' seconds from CPUs [0, 'max_cpu'] CPUs."
  echo "Require three arguments: file interval max_cpu"
  exit 1
fi

file=$1
interval=$2
max_cpu=$3

while true
do
  cpu_temp=$(cat /sys/class/thermal/thermal_zone0/temp)
  freq=$(average_freq $max_cpu)

  record_statistics $file $cpu_temp $freq

  sleep $interval
done
