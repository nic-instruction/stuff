#!/bin/bash

gcloud compute instance-templates create ig-us-template \
--region=us-central1 \
--tags=network-lb \
--image-family=centos-7 \
--image-project=centos-cloud \
--machine-type=f1-micro \
--metadata=startup-script='#! /bin/bash
yum -y install httpd mod_php php-mysql mod_ssl unzip git
echo "<?php
phpinfo ();
?>" > /var/www/html/info.php
systemctl enable httpd
systemctl start httpd
setsebool -P httpd_can_network_connect_db=1
git clone https://github.com/nic-instruction/stuff.git
cp stuff/app/* /var/www/html/'
