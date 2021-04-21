#!/bin/bash

yum -y install httpd mod_php php-mysql mod_ssl unzip

echo "<?php

phpinfo ();

?>" > /var/www/html/info.php

systemctl start httpd

git clone https://github.com/nic-instruction/stuff.git

cp stuff/app/* /var/www/html/

# Then cd to /var/www/html/ and edit the php files to have your db address and connection info.

