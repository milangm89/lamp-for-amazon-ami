#!/bin/bash
# Author : Milan George

# Function for yum update

yum_update() {
yum -y update
}

while true; do
    read -p "Do you wish to do a yum update? " yn
    case $yn in
        [Yy]* ) yum_update; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

nec_inst() {

# Installing necessary utilities
echo "###############################################"
echo "Installing necessary utilities for this server"
echo "###############################################"
yum -y install epel-release mlocate expect telnet vim lynx git

}

while true; do
    read -p "Do you wish to install some necessary utilities for your server? " yn
    case $yn in
        [Yy]* ) nec_inst; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Setting Hostname for the server

set_hostname(){

	echo " \n "
	echo "Taking backup of existing /etc/sysconfig/network file"
	cp /etc/sysconfig/network /etc/sysconfig/network-`date +"%Y%m%d_%H%M%S"`
	read -p "Enter hostname you want to set: " new_hostname
	present_hostname_entry=`cat /etc/sysconfig/network | grep "HOSTNAME"`
	echo " Changing hostname in /etc/sysconfig/network file "
	sed -i "s/$present_hostname_entry/HOSTNAME=$new_hostname/g" /etc/sysconfig/network
	echo " "
	hostname $new_hostname
	echo " Restarting network service"
	/etc/init.d/network reload
	/etc/init.d/network restart
	echo "You have set your hostname as $new_hostname"
	echo "Reboot the server to make it effective "

}

while true; do
    read -p "Do you wanna set hostname for this server? " yn
    case $yn in
        [Yy]* ) set_hostname; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Changing port and enabling password auth in ssh

ssh_conf() {

	echo "###############################################"
	echo "Changing ssh configuration"
	echo "###############################################"
	echo " "
	echo "Taking backup of the sshd config file on the same folder \n"
	#cp -r /etc/ssh/sshd_config /etc/ssh/sshd_config_orig
	cp -rpf /etc/ssh/sshd_config /etc/ssh/sshd_config-`date +"%Y%m%d_%H%M%S"`

	echo "Changing ssh port to 64567"
	if  `grep -q "Port 64567" /etc/ssh/sshd_config`
		then
			echo "Port already changed to 64567"
		else
			sed -i '/#Port 22/a Port 64567' /etc/ssh/sshd_config
	fi

	echo "Changing password authentication to yes"
	if  `grep -q "PasswordAuthentication yes" /etc/ssh/sshd_config`
		then
			echo "Password authentication already changed to yes"
		else
			present_pwd_auth_entry=`cat /etc/ssh/sshd_config | grep "PasswordAuthentication" | head -1`
			new_pwd_auth_entry="PasswordAuthentication yes"
			sed -i "s/$present_pwd_auth_entry/$new_pwd_auth_entry/g" /etc/ssh/sshd_config
	fi
			echo "Allowing root login "
			sed -e '/PermitRootLogin/ s/^#*/#/' -i /etc/ssh/sshd_config
			sed -i '/PermitRootLogin yes/s/^#//g' /etc/ssh/sshd_config

			echo "Restarting sshd service"
			/etc/init.d/sshd restart

}

while true; do
    read -p "Do you wish to change the ssh port to 64567 and permit root login? " yn
    case $yn in
        [Yy]* ) ssh_conf; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Installing Apache service

apache_24() {
echo "Removing existing packages"
rpm -e httpd* mod_ssl
echo "Installing Apache 2.4 packages"
yum -y install httpd24 httpd24-devel httpd24-tools mod24_ssl
echo "Installed Apache 2.4 packages"
echo "Starting Apache service"
/etc/init.d/httpd start
chkconfig httpd on
}

apache_22() {
echo "Removing existing packages"
rpm -e httpd* mod_ssl mod24_ssl
echo "Installing Apache 2.2 packages"
yum -y install httpd httpd-devel httpd-tools mod_ssl
echo "Installed Apache 2.2 packages"
echo "Starting Apache service"
/etc/init.d/httpd start
chkconfig httpd on
}

PS3='Which Apache version do you wish to install? Please enter your choice: '
options=("Apache 2.4" "Apache 2.2" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Apache 2.4")
            echo "You have selected Apache 2.4"
            apache_24
            break
            ;;
        "Apache 2.2")
            echo "You have selected Apache 2.2"
            apache_22
            break
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done

mysql_57() {
echo "Removing existing packages"
rpm -e --nodeps $(rpm -qa | grep -i mysql | grep -v php)
echo "Installing MySQL 5.7 packages"
yum -y install mysql57 mysql57-server
echo "Installed MySQL 5.7 packages"
echo "Starting MySQL services"
/etc/init.d/mysqld start
chkconfig mysqld on
echo "Setting MySQL password"
mys_pwd=$(mkpasswd -l 16)
/usr/libexec/mysql57/mysqladmin -u root password '$mys_pwd'
mysql -u root -p'$mys_pwd' -e "SET PASSWORD FOR 'root'@'localhost'= PASSWORD('$mys_pwd');"
echo "MySQL password is set to "$mys_pwd" "
echo "Adding MySQL password to /root/.my.cnf"
echo -e "[client]\nuser=root\npassword='$mys_pwd'" > /root/.my.cnf
}

mysql_56() {
echo "Removing existing packages"
rpm -e --nodeps `rpm -qa | grep -i mysql | grep -v php`
echo "Installing MySQL 5.6 packages"
yum -y install mysql56 mysql56-server
echo "Installed MySQL 5.6 packages"
echo "Starting MySQL services"
/etc/init.d/mysqld start
chkconfig mysqld on
echo "Setting MySQL password"
mys_pwd=$(mkpasswd -l 16)
/usr/libexec/mysql56/mysqladmin -u root password '$mys_pwd'
mysql -u root -p'$mys_pwd' -e "SET PASSWORD FOR 'root'@'localhost'= PASSWORD('$mys_pwd');"
echo "MySQL password is set to "$mys_pwd" "
echo "Adding MySQL password to /root/.my.cnf "
echo -e "[client]\nuser=root\npassword='$mys_pwd'" > /root/.my.cnf
}

mysql_55() {
echo "Removing existing packages"
rpm -e --nodeps $(rpm -qa | grep -i mysql | grep -v php)
echo "Installing MySQL 5.5 packages"
yum -y install mysql55 mysql55-server
echo "Installed MySQL 5.5 packages"
echo "Starting MySQL services"
/etc/init.d/mysqld start
chkconfig mysqld on
echo "Setting MySQL password"
mys_pwd=$(mkpasswd -l 16)
/usr/libexec/mysql55/mysqladmin -u root password '$mys_pwd'
mysql -u root -p'$mys_pwd' -e "SET PASSWORD FOR 'root'@'localhost'= PASSWORD('$mys_pwd');"
echo "MySQL password is set to '$mys_pwd'"
echo "Adding MySQL password to /root/.my.cnf"
echo -e "[client]\nuser=root\npassword='$mys_pwd'" > /root/.my.cnf
}

PS3='Which MySQL version do you wish to install? Please enter your choice: '
options=("MySQL 5.7" "MySQL 5.6" "MySQL 5.5" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "MySQL 5.7")
            echo "You have selected MySQL 5.7"
            mysql_57
            break
            ;;
        "MySQL 5.6")
            echo "You have selected MySQL 5.6"
            mysql_56
            break
            ;;
        "MySQL 5.5")
            echo "You have selected MySQL 5.5"
            mysql_55
            break
            ;;
        "Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done

install_php71() {
apache_ver=$(httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2)
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps $(rpm -qa | grep php | grep -v -i myadmin)
echo "Installing PHP 7.1 packages"
yum -y install php71 php71-common php71-devel php71-gd php71-imap php71-intl php71-mbstring php71-mcrypt php71-mysqlnd php7-pear php71-soap
echo "Installed PHP 7.1 packages"
echo "Restarting Apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

install_php70() {
apache_ver=$(httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2)
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps $(rpm -qa | grep php | grep -v -i myadmin)
echo "Installing PHP 7.0 packages"
yum -y install php70 php70-common php70-devel php70-gd php70-imap php70-intl php70-mbstring php70-mcrypt php70-mysqlnd php7-pear php70-soap
echo "Installed PHP 7.0 packages"
echo "Restarting Apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

install_php56() {
apache_ver=$(httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2)
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps $(rpm -qa | grep php | grep -v -i myadmin)
echo "Installing PHP 5.6 packages"
yum -y install php56 php56-common php56-devel php56-gd php56-imap php56-intl php56-mbstring php56-mcrypt php56-mysqlnd php-pear
echo "Installed PHP 5.6 packages"
echo "Restarting Apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

install_php55() {
apache_ver=$(httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2)
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps `rpm -qa | grep php | grep -v -i myadmin`
echo "Installing PHP 5.5 packages"
yum -y install php55 php55-common php55-devel php55-gd php55-imap php55-intl php55-mbstring php55-mcrypt php55-mysqlnd php-pear
echo "Installed PHP 5.5 packages"
echo "Restarting Apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version"
fi
}

install_php53() {
apache_ver=$(httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2)
ver_check=2.4
if [ "$apache_ver" != "$ver_check" ];
	then
		echo "Removing existing packages if any"
		rpm -e --nodeps $(rpm -qa | grep php | grep -v -i myadmin)
		echo "Installing PHP 5.3 packages"
		yum -y install php php-common php-devel php-gd php-imap php-intl php-mbstring php-mcrypt php-mysqlnd php-pear
		echo "Installed PHP 5.3 packages"
		echo "Restarting apache service"
		/etc/init.d/httpd restart
	else
		echo "The selected php version is not compatible with the installed apache version "
fi
}

PS3='Which PHP version do you wish to install? Please enter your choice: '
options=( "PHP 7.1" "PHP 7.0" "PHP 5.6" "PHP 5.5" "PHP 5.3" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "PHP 7.1")
            echo "You have selected PHP 7.1"
            install_php71
            break
            ;;
        "PHP 7.0")
            echo "You have selected PHP 7.0"
            install_php70
            break
            ;;
        "PHP 5.6")
            echo "You have selected PHP 5.6"
            install_php56
            break
            ;;
        "PHP 5.5")
            echo "You have selected PHP 5.5"
            install_php55
            break
            ;;
        "PHP 5.3")
            echo "You have selected PHP 5.3"
            install_php53
            break
            ;;
	"Quit")
            break
            ;;
        *) echo invalid option;;
    esac
done

install_phpmyadmin() {
php_ver=$(php -v | head -1 | awk '{print $2}' | cut -d . -f1,2)
apache_ver=$(httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2)

if `rpm -qa | grep -q -i phpmyadmin`
        then
                echo ""
                echo "phpMyadmin already installed!"
                echo ""
    else if [ "$php_ver" == "7.0" ] || [ "$php_ver" == "7.1" ]
            then
                echo "phpMyadmin cannot be installed on the installed php version $php_ver "
        else
                echo "Installing phpMyadmin"
                yum -y --enablerepo=epel install phpmyadmin
                /etc/init.d/httpd restart

                        if [ "$apache_ver" == "2.4" ];
                        then
                                sed -i '0,/<RequireAny>/s//<RequireAny>\nRequire all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
                                echo "Restarting Apache service"
                                /etc/init.d/httpd restart
                        else
                                sed -i '0,/# Apache 2.2/s//# Apache 2.2\nAllow from all/' /etc/httpd/conf.d/phpMyAdmin.conf
                                echo "Restarting Apache service"
                                /etc/init.d/httpd restart
                        fi
                fi
        fi
}

while true; do
    echo ""
    read -p "Do you wanna install phpMyadmin? " yn
    case $yn in
        [Yy]* ) install_phpmyadmin; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no";;
    esac
done

install_swap() {
if free | awk '/^Swap:/ {exit !$2}'; then
    echo "Swap already enabled"
else
read -p "How much swap pace required ? (Please mention it in GB): " swaps
if [[ ! $swaps || $swaps = *[^0-9]* ]]; then
    echo "Error: '$swaps' is not a valid swap space entry. Please enter number of GB you require" >&2
else
fallocate -l ${swaps}G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
swapon -s
echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab
fi
fi
}

while true; do
    read -p "Do you wish to enable Swap? " yn
    case $yn in
        [Yy]* ) install_swap; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

sftp_create() {

if [ -f /usr/bin/mysecureshell ] || [ -f /bin/MySecureShell ] ; then
    echo "Previous sftp installation found! Aborting Installation!! "
    else
echo "Installing Mysecureshell sftp package"
yum -y install gcc glibc glibc-common gd gd-devel perl-Env
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

cp -rpf /etc/ssh/sshd_config /etc/ssh/sshd_config-`date +"%Y%m%d_%H%M%S"`

sed -e '/AddressFamily/ s/^#*/#/' -i /etc/ssh/sshd_config
sed -i  '/#AddressFamily any/a AddressFamily inet' /etc/ssh/sshd_config

sed -e '/Subsystem sftp/ s/^#*/#/' -i /etc/ssh/sshd_config
sed -i '/Subsystem sftp/a Subsystem sftp /usr/bin/mysecureshell -c sftp-server' /etc/ssh/sshd_config

echo "Making changes in sftp_config"

cp -rpf /etc/ssh/sftp_config /etc/ssh/sftp_config-`date +"%Y%m%d_%H%M%S"`

sed -e '/GlobalDownload/ s/^#*/#/' -i /etc/ssh/sftp_config
sed -i '/#\tGlobalDownload/a GlobalDownload\t0' /etc/ssh/sftp_config

sed -e '/LimitConnectionByUser/ s/^#*/#/' -i /etc/ssh/sftp_config
sed -i '/#\tLimitConnectionByUser/a LimitConnectionByUser\t5' /etc/ssh/sftp_config

sed -e '/LimitConnectionByIP/ s/^#*/#/' -i /etc/ssh/sftp_config
sed -i '/LimitConnectionByIP/a LimitConnectionByIP\t5' /etc/ssh/sftp_config
awk '/LimitConnectionByIP\t5/&&c++>0 {next} 1' /etc/ssh/sftp_config > /etc/ssh/sftp_config_new
mv -f /etc/ssh/sftp_config_new /etc/ssh/sftp_config

#the below single line can be used instead of the above 3 lines#
#sed -i  '/#\tLimitConnectionByIP\t2/a LimitConnectionByIP\t5' sftp_config

#sed -e '/StayAtHome/ s/^#*/#/' -i sftp_config
#sed -i  '/#StayAtHome/a StayAtHome  true' sftp_config

sed -e '/\bHome\b/ s/^#*/#/' -i /etc/ssh/sftp_config

sed -i '/ResolveIP/a ForceUser\tapache\nForceGroup\tapache\nDisableSetAttribute\ttrue' /etc/ssh/sftp_config

sed -e '/DefaultRights/ s/^#*/#/' -i /etc/ssh/sftp_config
sed -i  '/#\tDefaultRights/a DefaultRights\t0644\t0755' /etc/ssh/sftp_config

sed -i '/sftp_administrator/s/^#//g' /etc/ssh/sftp_config
sed -i '/#\tStayAtHome\ttrue/s/^#//g' /etc/ssh/sftp_config
sed -i '/#\tIdleTimeOut\t0/a </Group>' /etc/ssh/sftp_config

echo "Creating sftp group"
groupadd sftp_administrator
echo "Creating SFTP user"
useradd -m -d /var/www/html -s /usr/bin/mysecureshell sftpuser
pwd_sftp=$(mkpasswd -l 16)
echo "$pwd_sftp" | passwd sftpuser --stdin

echo "Changing ownership of /var/www/html to apache"
chown -R apache:apache /var/www/html/
usermod -a -G apache sftpuser

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
