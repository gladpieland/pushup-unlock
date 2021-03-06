#!/usr/bin/env bash
export DISPLAY=:0
current_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
working_dir="$(dirname $current_dir)"
log_file=$current_dir/logs/op.log
pushup_counter_path="src/pushup_counter.py"
pid_path="$working_dir/rspi/dest/pid"

echo "launch pushup counter - current_dir is $current_dir" >> $log_file

source $current_dir/dest/env.sh

# 1. kill previous counter process if exist
if test -f "$pid_path"; then
  prev_pid="`cat $pid_path`"
  if [[ -n $prev_pid ]]; then
    echo "begin kill previous counter process#$prev_pid" >> $log_file
    kill_msg=`kill -9 $prev_pid`
    echo "done kill counter process: $kill_msg" >> $log_file
  fi
fi

# 2. run counter
if test -z "$py_home_dir" 
then
  python3 $working_dir/$pushup_counter_path >> $log_file  2>&1 &
else
  if test -f "$py_home_dir/bin/python3"
  then
    $py_home_dir/bin/python3  $working_dir/$pushup_counter_path >> $log_file  2>&1 &
  else
    $py_home_dir/python3  $working_dir/$pushup_counter_path >> $log_file  2>&1 &
  fi
fi

echo "Push-up counter launched." >> $log_file

echo "READY"

exit 0
