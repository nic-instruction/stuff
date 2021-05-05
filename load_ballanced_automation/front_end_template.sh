#!/bin/bash

# create instance template
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

# create instance group that will reference template (in first zone)

gcloud compute instance-groups managed create ig-us-1 \
    --zone us-central1-a \
    --size 2 \
    --template ig-us-template
    
# create instance group that will reference template (in second zone)

gcloud compute instance-groups managed create ig-us-2 \
    --zone us-central1-c \
    --size 2 \
    --template ig-us-template

# create a firewall rule that allows network-1b tagged instances to come in on port 80

gcloud compute firewall-rules create allow-network-lb \
    --target-tags network-lb \
    --allow tcp:80    
    
# configure static ip address for load balancer

gcloud compute addresses create network-lb-ip \
    --region us-central1

# create tcp health check

gcloud compute health-checks create tcp tcp-health-check \
    --region us-central1 \
    --port 80
    
# create backend group

gcloud compute backend-services create network-lb-backend-service \
    --protocol TCP \
    --health-checks tcp-health-check \
    --health-checks-region us-central1 \
    --region us-central1
    
# add instance groups to the backend service

gcloud compute backend-services add-backend network-lb-backend-service \
--instance-group ig-us-1 \
--instance-group-zone us-central1-a \
--region us-central1

gcloud compute backend-services add-backend network-lb-backend-service \
--instance-group ig-us-2 \
--instance-group-zone us-central1-c \
--region us-central1

# create a forwarding rule to route incoming tcp traffic to the backend service

gcloud compute forwarding-rules create network-lb-forwarding-rule \
    --load-balancing-scheme external \
    --region us-central1 \
    --ports 80 \
    --address network-lb-ip \
    --backend-service network-lb-backend-service
    
# get the forwarding rule ip address

gcloud compute forwarding-rules describe network-lb-forwarding-rule --region us-central1 | grep IPAddress: | awk -F ":" '{print $2}'
    
