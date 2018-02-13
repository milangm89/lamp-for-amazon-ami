#!/bin/bash

sftp_create() {

if [ -f /usr/bin/mysecureshell ] || [ -f /bin/MySecureShell ] ; then
    echo "Previous sftp installation found! Aborting Installation!! "
    else
echo "Installing Mysecureshell sftp package"
yum -y install gcc glibc glibc-common gd gd-devel 
cd /usr/local/src/
git clone https://github.com/mysecureshell/mysecureshell.git
cd mysecureshell/
./configure
make
make install

echo "#################################################"
echo "Mysecureshell sftp package installation completed"
echo "#################################################"

echo "Making changes in sshd configuration"

sed -e '/AddressFamily/ s/^#*/#/' -i /root/lamp/sshd_config
sed -i  '/#AddressFamily any/a AddressFamily inet' /root/lamp/sshd_config

sed -e '/Subsystem sftp/ s/^#*/#/' -i /root/lamp/sshd_config
sed -i '/Subsystem sftp/a Subsystem sftp /usr/bin/mysecureshell -c sftp-server' /root/lamp/sshd_config

echo "Making changes in sftp_config"

sed -e '/GlobalDownload/ s/^#*/#/' -i /root/lamp/sftp_config
sed -i '/#\tGlobalDownload/a GlobalDownload\t0' sftp_config

sed -e '/LimitConnectionByUser/ s/^#*/#/' -i /root/lamp/sftp_config
sed -i '/#\tLimitConnectionByUser/a LimitConnectionByUser\t5' sftp_config

sed -e '/LimitConnectionByIP/ s/^#*/#/' -i /root/lamp/sftp_config
sed -i '/LimitConnectionByIP/a LimitConnectionByIP\t5' /root/lamp/sftp_config
awk '/LimitConnectionByIP\t5/&&c++>0 {next} 1' /root/lamp/sftp_config > /root/lamp/sftp_config_new
mv -f /root/lamp/sftp_config_new /root/lamp/sftp_config

#the below single line can be used instead of the above 3 lines#
#sed -i  '/#\tLimitConnectionByIP\t2/a LimitConnectionByIP\t5' sftp_config

#sed -e '/StayAtHome/ s/^#*/#/' -i sftp_config
#sed -i  '/#StayAtHome/a StayAtHome  true' sftp_config

sed -e '/\bHome\b/ s/^#*/#/' -i /root/lamp/sftp_config

sed -i '/ResolveIP/a ForceUser\tapache\nForceGroup\tapache\nDisableSetAttribute\ttrue' /root/lamp/sftp_config

sed -e '/DefaultRights/ s/^#*/#/' -i /root/lamp/sftp_config
sed -i  '/#\tDefaultRights/a DefaultRights\t0644\t0755' /root/lamp/sftp_config

sed -i '/sftp_administrator/s/^#//g' /root/lamp/sftp_config
sed -i '/#\tStayAtHome\ttrue/s/^#//g' /root/lamp/sftp_config
sed -i '/#\tIdleTimeOut\t0/a </Group>' /root/lamp/sftp_config

echo "Creating sftp group"
groupadd sftp_administrator
echo "Creating SFTP user"
useradd -m -d /var/www/html/ -s /usr/bin/mysecureshell sftpuser
pwd_sftp=`mkpasswd -l 15`
echo "$pwd_sftp" | passwd sftpuser --stdin

echo "Changing ownership of /var/www/html to apache"
chown -R apache:apache /var/www/html/
echo "Restarting ssh service"
/etc/init.d/sshd restart
echo " The username is : sftpuser and the password is : $pwd_sftp "

fi
}

while true; do
    read -p "Do you wish to create sftp for this server? " yn
    case $yn in
        [Yy]* ) sftp_create; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
