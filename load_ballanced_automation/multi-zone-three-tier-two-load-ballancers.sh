#!/bin/bash
# This is based on design from this doc: https://cloud.google.com/load-balancing/docs/internal/setting-up-internal#gcloud_1
# with an additional load balancing tier thrown in front of the DB backend for added security
# also had to use some features from this: https://www.qwiklabs.com/focuses/642?parent=catalog
# And in the end, it didn't end up being much like either.  Sigh!  This is a 2 -3 tier system with load ballancers between the pieces on isolated subnets.


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

# Just added this one, not in the burndown script, and hasn't been tested
gcloud compute firewall-rules create www-firewall \
    --network=nic-load-balancing-network \
    --action=allow \
    --direction=ingress \
    --target-tags http-tag \
    --rules=tcp:80
    

# So far we've made a couple deviations from the tutorial, here, we're going to use managed instance groups with a template
# added tag --tags=allow-ssh,allow-health-check to previous automation template
gcloud compute instance-templates create nic-load-balancing-template \
--region=us-central1 \
--tags=nic-load-balancing-network \
--subnet=nic-load-balancing-network-subnet \
--image-family=centos-7 \
--image-project=centos-cloud \
--machine-type=f1-micro \
--tags=allow-ssh,allow-health-check,http-tag \
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

gcloud compute instance-templates create nic-load-balancing-template-w1 \
--region=us-west1 \
--tags=nic-load-balancing-network \
--subnet=nic-load-balancing-network-subnet \
--image-family=centos-7 \
--image-project=centos-cloud \
--machine-type=f1-micro \
--tags=allow-ssh,allow-health-check,http-tag \
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

gcloud compute instance-groups managed create nic-load-balancing-ig-cc \
    --zone us-central1-c \
    --size 2 \
    --template nic-load-balancing-template
  
# create instance group that will refrence template (in west1-a zone)
gcloud compute instance-groups managed create nic-load-balancing-ig-wa \
    --zone us-west1-a \
    --size 2 \
    --template nic-load-balancing-template-w1

# create instance group that will reference template (in west1-c zone)
gcloud compute instance-groups managed create nic-load-balancing-ig-wc \
    --zone us-west1-c \
    --size 2 \
    --template nic-load-balancing-template-w1
    

    
gcloud compute instance-groups set-named-ports nic-load-balancing-ig-ca \
    --named-ports=http:80 \
    --zone us-central1-a   
    
gcloud compute instance-groups set-named-ports nic-load-balancing-ig-cc \
    --named-ports=http:80 \
    --zone us-central1-c
    
gcloud compute instance-groups set-named-ports nic-load-balancing-ig-wa \
    --named-ports=http:80 \
    --zone us-west1-a
    
gcloud compute instance-groups set-named-ports nic-load-balancing-ig-wc \
    --named-ports=http:80 \
    --zone us-west1-c
    
# set named ports!!!!


# create new health-check service in west1
#gcloud compute health-checks create http hc-http-80 \
#    --region=us-west1 \
#    --port=80

# create new health-check service in central1
#gcloud compute health-checks create http hc-http-80 \
#    --region=us-central1 \
#    --port=80

# health check was not in place, possibly this was the issue!
gcloud compute health-checks create http http-basic-check
    
gcloud compute backend-services create web-map-backend-service \
    --protocol HTTP \
    --health-checks http-basic-check \
    --global   
    

gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group=nic-load-balancing-ig-wa \
    --instance-group-zone=us-west1-a \
    --global
    
gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group=nic-load-balancing-ig-wc \
    --instance-group-zone=us-west1-c \
    --global
    
gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group=nic-load-balancing-ig-ca \
    --instance-group-zone=us-central1-a \
    --global
    
gcloud compute backend-services add-backend web-map-backend-service \
    --balancing-mode UTILIZATION \
    --max-utilization 0.8 \
    --capacity-scaler 1 \
    --instance-group=nic-load-balancing-ig-cc \
    --instance-group-zone=us-central1-c \
    --global
    
gcloud compute url-maps create web-map \
    --default-service web-map-backend-service
    
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map

gcloud compute addresses create lb-ipv4-1 \
  --ip-version=IPV4 \
  --global    
    
external_addy=$(gcloud compute addresses list | grep lb-ipv4-1 | awk '{print $2}')

gcloud compute forwarding-rules create http-cr-rule \
    --address $external_addy \
    --global \
    --target-http-proxy http-lb-proxy \
    --ports 80
    
forwarding_rule_addy=$(gcloud compute forwarding-rules list | grep http-cr-rule | awk '{print $2}')

#problem: backend service is unhealthy.


#  REMOVE FROM HERE TO    
# create new backend service for west1

    

  
# HERE  CUT IT ALLL!!!! (IF THIS WORKS) 
 # DB BACKENDS
 
 # Create a subnet of our new network on us-west1
gcloud compute networks subnets create nic-db-backend-network-subnet \
    --network=nic-load-balancing-network \
    --range=10.1.4.0/24 \
    --region=us-west1

# Create a subnet of our new network on us-central1
gcloud compute networks subnets create nic-db-backend-network-subnet \
    --network=nic-load-balancing-network \
    --range=10.1.5.0/24 \
    --region=us-central1
    
    
# create fw rules

gcloud compute firewall-rules create fw-allow-db-backend-network-access \
    --network=nic-load-balancing-network \
    --action=allow \
    --direction=ingress \
    --source-ranges=10.1.4.0/24,10.1.5.0/24 \
    --rules=tcp,udp,icmp
    
# ssh is already in place.  No health check for now

# db cluster configuration is a thing with a r/w node and ro nodes, we won't do that in this script because I don't have time today
# but we'll cover it in class and script it.

