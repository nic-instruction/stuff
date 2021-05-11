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
    
    
