read -p "Enter hostname you want to set: " new_hostname
present_hostname_entry=`cat /root/lamp/network | grep "HOSTNAME"`
echo " Changing hostname in network file "
sed -i "s/$present_hostname_entry/HOSTNAME=$new_hostname/g" /root/lamp/network
echo " "
hostname $new_hostname
echo " Restarting network service"
/etc/init.d/network restart
echo "You have set your hostname as $new_hostname"
echo "Reboot the server to make it effective "

while true; do
    read -p "Do you wanna set hostname for this server?" yn
    case $yn in
        [Yy]* ) set_hostname; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
