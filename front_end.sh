#!/bin/bash

yum -y install httpd mod_php php-mysql mod_ssl

echo "<?php

phpinfo ();

?>" > /var/www/html/info.php

systemctl start httpd
