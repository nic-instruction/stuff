#!/bin/bash

yum -y install httpd mod_php php-mysql mod_ssl unzip git

echo "<?php

phpinfo ();

?>" > /var/www/html/info.php

systemctl enable httpd
systemctl start httpd

git clone https://github.com/nic-instruction/stuff.git

cp stuff/app/* /var/www/html/

# Then cd to /var/www/html/ and edit the php files to have your db address and connection info.
# Automate this part using git or wget and sed for the password and db search and replace on the php files.  
# remember that the git clone dir will be in /root.

