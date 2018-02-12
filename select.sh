#!/bin/bash
# Bash Menu Script Example
# Installing Apache service

apache_24() {
echo "Removing existing packages"
rpm -e --nodeps `rpm -qa | grep "httpd\|mod_ssl\|mod24_ssl"`
echo "Installing Apache 2.4 packages"
yum  -y install httpd24 httpd24-devel httpd24-tools mod24_ssl
echo "Installed Apache 2.4 packages"
echo "Starting Apache service"
/etc/init.d/httpd restart
}

apache_22() {
echo "Removing existing packages"
rpm -e --nodeps `rpm -qa | grep "httpd\|mod_ssl\|mod24_ssl"`
echo "Installing Apache 2.2 packages"
yum -y install httpd httpd-devel httpd-tools mod_ssl
echo "Installed Apache 2.2 packages"
echo "Starting Apache service"
/etc/init.d/httpd restart
}

PS3='Which Apache version do you want to install? Please enter your choice: '
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
rpm -e --nodeps `rpm -qa | grep -i mysql | grep -v php`
echo "Installing MySQL 5.7 packages"
yum -y install mysql57 mysql57-server
echo "Installed MySQL 5.7 packages"
echo "Starting MySQL services"
/etc/init.d/mysqld start
chkconfig mysqld on
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
}

mysql_55() {
echo "Removing existing packages"
rpm -e --nodeps `rpm -qa | grep -i mysql | grep -v php`
echo "Installing MySQL 5.5 packages"
yum -y install mysql55 mysql55-server
echo "Installed MySQL 5.5 packages"
echo "Starting MySQL services"
/etc/init.d/mysqld start
chkconfig mysqld on
}

PS3='Which MySQL version do you want to install? Please enter your choice: '
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
apache_ver=`httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2`
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps `rpm -qa | grep php | grep -v -i myadmin`
echo "Installing PHP 7.1 packages"
yum -y install php71 php71-common php71-devel php71-gd php71-imap php71-intl php71-mbstring php71-mcrypt php71-mysqlnd php7-pear php71-soap
echo "Installed PHP 7.1 packages"
echo "Restarting apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

install_php70() {
apache_ver=`httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2`
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps `rpm -qa | grep php | grep -v -i myadmin`
echo "Installing PHP 7.0 packages"
yum -y install php70 php70-common php70-devel php70-gd php70-imap php70-intl php70-mbstring php70-mcrypt php70-mysqlnd php7-pear php70-soap
echo "Installed PHP 7.0 packages"
echo "Restarting apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

install_php56() {
apache_ver=`httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2`
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps `rpm -qa | grep php | grep -v -i myadmin`
echo "Installing PHP 5.6 packages"
yum -y install php56 php56-common php56-devel php56-gd php56-imap php56-intl php56-mbstring php56-mcrypt php56-mysqlnd php56-soap php-pear
echo "Installed PHP 5.6 packages"
echo "Restarting apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

install_php55() {
apache_ver=`httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2`
ver_check=2.4
if [ "$apache_ver" == "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps `rpm -qa | grep php | grep -v -i myadmin`
echo "Installing PHP 5.5 packages"
yum -y install php55 php55-common php55-devel php55-gd php55-imap php55-intl php55-mbstring php55-mcrypt php55-mysqlnd php55-soap php-pear
echo "Installed PHP 5.5 packages"
echo "Restarting apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

install_php53() {
apache_ver=`httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2`
ver_check=2.4
if [ "$apache_ver" != "$ver_check" ];
then
echo "Removing existing packages if any"
rpm -e --nodeps `rpm -qa | grep php | grep -v -i myadmin`
echo "Installing PHP 5.3 packages"
yum -y install php php-common php-devel php-gd php-imap php-intl php-mbstring php-mcrypt php-mysqlnd php-pear
echo "Installed PHP 5.3 packages"
echo "Restarting apache service"
/etc/init.d/httpd restart
else
echo "The selected php version is not compatible with the installed apache version "
fi
}

PS3='Which PHP version do you want to install? Please enter your choice: '
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
