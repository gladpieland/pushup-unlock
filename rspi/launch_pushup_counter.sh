#!/usr/bin/env bash
export DISPLAY=:0
current_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
working_dir="$(dirname $current_dir)"
log_file=$current_dir/logs/op.log

echo "launch pushup counter - current_dir is $current_dir" >> $log_file

source $current_dir/dest/env.sh

pushup_counter_path="src/pushup_counter.py"

pushd $working_dir
if test -z "$py_home_dir" 
then
  python3 $working_dir/$pushup_counter_path
else
  if test -f "$py_home_dir/bin/python3"
  then
    $py_home_dir/bin/python3  $working_dir/$pushup_counter_path
  else
    $py_home_dir/python3  $working_dir/$pushup_counter_path
  fi
fi

echo "Push-up counter launched." >> $log_file
popd

echo "READY"
