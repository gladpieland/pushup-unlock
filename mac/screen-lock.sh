current_dir=${pwd}
log_file=$current_dir/logs/op.log
source $current_dir/dest/env.sh

echo "begin lock, at `date`" >> $log_file
echo "`ls -l ${current_dir}/dest/lockscreen` " >> $log_file

# 1. launch push-up counter in remote raspberry pi
ssh pi@$rspi_host_ip "$rspi_shell_dir/launch_pushup_counter.sh"

# 2. lock screen
${current_dir}/dest/lockscreen

echo "done lock, `date`" >> $log_file