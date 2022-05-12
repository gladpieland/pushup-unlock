current_dir=${PWD}

# 1. record host ip and shell path in raspberry pi
cp $current_dir/env.sh $current_dir/dest/env.sh
sed -i '' -e "s/{py_home_dir}/${py_home_dir}/g" $current_dir/dest/env.sh

echo 'Please enter Python home direcotry(for example: ~/.virtualenvs/pushup): '
read -r py_home_dir

if test -z "$py_home_dir" 
then
  py_home_dir=""
else
  py_home_dir="$py_home_dir"
fi

# 3. record host ip and shell path in Mac machine
echo 'Please enter Username for screen unlock in remote Mac machine: '
read -r mac_username
echo 'Please enter host IP of remote Mac machine: '
read -r mac_host_ip
echo 'Please enter script directory in remote Mac machine: '
read -r mac_shell_dir

sed -i '' -e "s/{mac_username}/${mac_username}/g" $current_dir/dest/env.sh
sed -i '' -e "s/{mac_host_ip}/${mac_host_ip}/g" $current_dir/dest/env.sh
sed -i '' -e "s#{mac_shell_dir}#${mac_shell_dir}#g" $current_dir/dest/env.sh

