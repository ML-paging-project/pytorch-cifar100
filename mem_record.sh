pid=$1

while true; do
   cat /proc/$pid/status |grep VmRSS >> result/mem-$pid.txt
   sleep 1
done