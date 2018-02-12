#!/bin/bash

sftp_create() {
echo "Installing Mysecureshell sftp package"
yum -y install gcc glibc glibc-common gd gd-devel 
cd /usr/local/src/
git clone https://github.com/mysecureshell/mysecureshell.git
cd mysecureshell/
./configure
make
make install
echo "Mysecureshell sftp package installation completed"

echo "Making changes in sshd configuration"

sed -e '/AddressFamily/ s/^#*/#/' -i sshd_config
sed -i  '/#AddressFamily any/a AddressFamily inet' sshd_config

sed -e '/Subsystem sftp/ s/^#*/#/' -i sshd_config
sed -i '/Subsystem sftp/a Subsystem sftp /usr/bin/mysecureshell -c sftp-server' sshd_config

echo "Making changes in sftp_config"

sed -e '/GlobalDownload/ s/^#*/#/' -i sftp_config
sed -i  '/#\tGlobalDownload/a \tGlobalDownload\t0' sftp_config

sed -e '/LimitConnectionByUser/ s/^#*/#/' -i sftp_config
sed -i  '/#\tLimitConnectionByUser/a \tLimitConnectionByUser\t5' sftp_config

sed -e '/LimitConnectionByIP/ s/^#*/#/' -i sftp_config
sed -i  '/#\tLimitConnectionByIP/a \tLimitConnectionByIP 5' sftp_config

#sed -e '/StayAtHome/ s/^#*/#/' -i sftp_config
#sed -i  '/#StayAtHome/a StayAtHome  true' sftp_config

sed -e '/\bHome\b/ s/^#*/#/' -i sftp_config



}

while true; do
    read -p "Do you wish to create sftp for this server? " yn
    case $yn in
        [Yy]* ) sftp_create; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
