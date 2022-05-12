# source /home/pi/.bash_profile
export DISPLAY=:0
current_dir=${PWD}
working_dir="$(dirname `pwd`)"
echo "working_dir is $working_dir"

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

echo "Push-up counter launched."
popd
