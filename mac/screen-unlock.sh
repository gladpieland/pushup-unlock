 current_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
 echo "current_dir is $current_dir"
 
log_file=$current_dir/logs/op.log

echo "begin unlock, at `date`," >> $log_file

echo "`ls -l ${current_dir}/dest/unlockscreen.script` ">> $log_file

osascript ${fancy_home}/dest/unlockscreen.script

echo "done unlock, `date`" >> $log_file


