#!/bin/bash
# This is based on design from this doc:
# with an additional load balancing tier thrown in front of the DB backend for added security

# Create a new network for our load ballancing shinanagins
gcloud compute networks create nic-load-balancing-network --subnet-mode=custom


#Instances on this network will not be reachable until firewall rules
#are created. As an example, you can allow all internal traffic between
#instances as well as SSH, RDP, and ICMP by running:
#$ gcloud compute firewall-rules create <FIREWALL_NAME> --network nic-load-balancing-network --allow tcp,udp,icmp --source-ranges <IP_RANGE>
#$ gcloud compute firewall-rules create <FIREWALL_NAME> --network nic-load-balancing-network --allow tcp:22,tcp:3389,icmp

# Create a subnet of our new network on us-west1
gcloud compute networks subnets create nic-load-balancing-network-subnet \
    --network=nic-load-balancing-network \
    --range=10.1.2.0/24 \
    --region=us-west1

# Create a subnet of our new network on us-central1
gcloud compute networks subnets create nic-load-balancing-network-subnet \
    --network=nic-load-balancing-network \
    --range=10.1.3.0/24 \
    --region=us-central1

# Create firewall rules to allow communication from within the subnet
# Note: in a prod environment, locking this down to relevent protocols would be a good idea (you would need to configure new subnets or new 
# firewall rules for deployments that needed additional protocols, but that isn't a bad thing
gcloud compute firewall-rules create fw-allow-nic-load-balancing-network-access \
    --network=nic-load-balancing-network \
    --action=allow \
    --direction=ingress \
    --source-ranges=10.1.2.0/24,10.1.3.0/24 \
    --rules=tcp,udp,icmp
    
# Allow ssh from anywhere to instances tagged with allow-ssh on the network (if you don't put a source range, gcloud compute firewall-rules
# interprets that as 'from anywhere', just a heads up!)
gcloud compute firewall-rules create fw-allow-ssh \
    --network=nic-load-balancing-network \
    --action=allow \
    --direction=ingress \
    --target-tags=allow-ssh \
    --rules=tcp:22
    
# Allow Google healthchecks (we'll need these for our clusters/pools/backend-service instance groups)
gcloud compute firewall-rules create fw-allow-health-check \
    --network=nic-load-balancing-network \
    --action=allow \
    --direction=ingress \
    --target-tags=allow-health-check \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp,udp,icmp
    
# So far we've made a couple deviations from the tutorial, here, we're going to use managed instance groups with a template
# added tag --tags=allow-ssh,allow-health-check to previous automation template
gcloud compute instance-templates create nic-load-balancing-template \
--region=us-central1 \
--tags=nic-load-balancing-network \
--image-family=centos-7 \
--image-project=centos-cloud \
--machine-type=f1-micro \
--tags=allow-ssh,allow-health-check \
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

# create instance group that will reference template (in central1-a zone)

gcloud compute instance-groups managed create nic-load-balancing-ig-ca \
    --zone us-central1-a \
    --size 2 \
    --template nic-load-balancing-template 
    
# create instance group that will reference template (in central1-c zone)

gcloud compute instance-groups managed create nic-load-balancing-ig-cb \
    --zone us-central1-c \
    --size 2 \
    --template nic-load-balancing-template
  
# create instance group that will refrence template (in west1-a zone)
gcloud compute instance-groups managed create nic-load-balancing-ig-wa \
    --zone us-west1-a \
    --size 2 \
    --template nic-load-balancing-template 

# create instance group that will reference template (in west1-c zone)
gcloud compute instance-groups managed create nic-load-balancing-ig-wc \
    --zone us-west1-c \
    --size 2 \
    --template nic-load-balancing-template 
    
# create new health-check service in west1
gcloud compute health-checks create http hc-http-80 \
    --region=us-west1 \
    --port=80

# create new health-check service in central1
gcloud compute health-checks create http hc-http-80 \
    --region=us-central1 \
    --port=80
    
# create new backend service for west1
gcloud compute backend-services create nic-load-balancing-backend-service-lb-w1 \
    --load-balancing-scheme=internal \
    --protocol=tcp \
    --region=us-west1 \
    --health-checks=hc-http-80 \
    --health-checks-region=us-west1

# create new backend service for central1
gcloud compute backend-services create nic-load-balancing-backend-service-lb-c1 \
    --load-balancing-scheme=internal \
    --protocol=tcp \
    --region=us-central1 \
    --health-checks=hc-http-80 \
    --health-checks-region=us-central1
