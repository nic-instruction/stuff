#!/bin/bash

yum -y install httpd mod_php php-mysql mod_ssl unzip

echo "<?php

phpinfo ();

?>" > /var/www/html/info.php

systemctl start httpd

# upload files
# mv /home/nicolebade/helloworld\ \(1\).zip /var/www/html (replace nicolebade with your username)
# Now you can go to http://34.68.83.204/helloworld/index.php  (replace 34.68.83.204 with your ip) and see a page

# edit everything to connect to your database server!  (connection is in functions)

