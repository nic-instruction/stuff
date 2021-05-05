#!/bin/bash
# Written by aliyacodes (not nic-instruction)  Awesome automation!!

yum -y install phpmyadmin mysql httpd php mariadb-server
systemctl enable mariadb
systemctl enable httpd
systemctl start mariadb
systemctl start httpd

echo "CREATE DATABASE back_end;
USE back_end;
CREATE TABLE info (
    name varchar(255), 
    witticism varchar(1000), 
    sarcastic_gloat varchar(1000)
);
GRANT USAGE ON *.* TO \'MyApp\'@\'%\' IDENTIFIED BY PASSWORD \'*236023AE71553ECD5E234575E2EEC41C32263119\';
GRANT SELECT, INSERT, UPDATE, DELETE ON `back_end`.* TO \'MyApp\'@\'%\';" >> file

mysql < file

sed -i 's/Require ip 127.0.0.1/Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i 's/Allow from 127.0.0.1/Allow from All/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '/Allow from ::1/d' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '/Require ip ::1/d' /etc/httpd/conf.d/phpMyAdmin.conf
systemctl restart httpd
mysqladmin -u root password 'P@ssw0rd1'

sed -i '10 i bind-address=0.0.0.0' /etc/my.cnf

systemctl restart mariadb
