#!/usr/bin/env bash
current_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "current_dir is $current_dir"

log_file=$current_dir/logs/op.log
source $current_dir/dest/env.sh

echo "begin lock, at `date`" >> $log_file
echo "`ls -l ${current_dir}/dest/lockscreen` " >> $log_file

# 1. launch push-up counter in remote raspberry pi
launch_result=`ssh pi@$rspi_host_ip "$rspi_shell_dir/launch_pushup_counter.sh"`
echo "launch_result is $launch_result"
echo "launch_result is $launch_result" >> $log_file

# 2. lock screen
if [ "$launch_result" == "READY" ]
then
  ${current_dir}/dest/lockscreen
else
  echo "launch push-up counter fail, message: $launch_result" >> $log_file
  echo "-------------------------- message begin --------------------------" >> $log_file
  echo "$launch_result" >> $log_file
  echo "-------------------------- message done --------------------------" >> $log_file
fi

echo "done lock, `date`" >> $log_file