#!/bin/bash

echo "###############################################"
echo "Changing ssh configuration"
echo "###############################################"
echo " "
echo "Taking backup of the sshd config file on the same folder \n"
cp -rpf /root/lamp/sshd_config /root/lamp/sshd_config-`date +"%Y%m%d_%H%M%S"`

echo "Changing ssh port to 64567"
if  `grep -q "Port 64567" /root/lamp/sshd_config`
then
echo "Port already changed to 64567"
else
sed -i '/#Port 22/a Port 64567' /root/lamp/sshd_config
fi

echo "Changing password authentication to yes"
if  `grep -q "PasswordAuthentication yes" /root/lamp/sshd_config`
then
echo "Password authentication already changed to yes"
else
present_pwd_auth_entry=`cat /root/lamp/sshd_config | grep "PasswordAuthentication" | head -1`
new_pwd_auth_entry="PasswordAuthentication yes"
sed -i "s/$present_pwd_auth_entry/$new_pwd_auth_entry/g" /root/lamp/sshd_config
fi
echo "Allowing root login "
sed -e '/PermitRootLogin/ s/^#*/#/' -i /root/lamp/sshd_config
sed -i '/PermitRootLogin yes/s/^#//g' /root/lamp/sshd_config

echo "Restarting sshd service"
/etc/init.d/sshd restart
