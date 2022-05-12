current_dir=${PWD}
log_file=$current_dir/logs/op.log
source $current_dir/dest/env.sh


echo 'begin remote unlock' >> $log_file
ssh $mac_username@$mac_host_ip "$mac_shell_dir/screen-unlock.sh" >> $log_file  2>&1 &
echo 'done remote unlock' >> $log_file

