#!/bin/bash

apache_ver=`httpd -v | grep -i apache | awk '{print $3}' | cut -d / -f2 | cut -d . -f1,2`

if [ "$apache_ver" == "2.4" ];
then
echo "Apache version is 2.4"
else 
echo "Apache version 2.2"
fi
