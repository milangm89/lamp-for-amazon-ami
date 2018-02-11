#!/bin/bash
install_phpmyadmin() {
php_ver=`php -v | head -1 | awk '{print $2}' | cut -d . -f1,2`
apache_ver=`httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2`
ver_check=2.4

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
