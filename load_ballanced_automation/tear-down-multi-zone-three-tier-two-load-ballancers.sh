#!/bin/bash

# delte external load balancer
gcloud compute forwarding-rules delete http-cr-rule --global --quiet

# delete external address
gcloud compute addresses delete lb-ipv4-1 --global --quiet

# delete proxies
gcloud compute target-http-proxies delete http-lb-proxy --quiet

# delete url-map
gcloud compute url-maps delete web-map --quiet

# delete the backend service
gcloud compute backend-services delete web-map-backend-service --global --quiet

# delete health checks
gcloud compute health-checks delete http http-basic-check --global --quiet

# delete all instance-groups
gcloud compute instance-groups managed delete nic-load-balancing-ig-wc --zone us-west1-c --quiet
gcloud compute instance-groups managed delete nic-load-balancing-ig-wa  --zone us-west1-a --quiet
gcloud compute instance-groups managed delete nic-load-balancing-ig-cc  --zone us-central1-c --quiet
gcloud compute instance-groups managed delete nic-load-balancing-ig-ca --zone us-central1-a --quiet

# delete instance group templates
gcloud compute instance-templates delete nic-load-balancing-template --quiet
gcloud compute instance-templates delete nic-load-balancing-template-w1 --quiet

# remove firewall rules
gcloud compute firewall-rules delete fw-allow-health-check --quiet
gcloud compute firewall-rules delete fw-allow-ssh --quiet
gcloud compute firewall-rules delete fw-allow-nic-load-balancing-network-access --quiet
gcloud compute firewall-rules delete www-firewall --quiet

# delete the subnets
gcloud compute networks subnets delete nic-db-backend-network-subnet --region us-west1 --quiet
gcloud compute networks subnets delete nic-db-backend-network-subnet --region us-central1 --quiet
gcloud compute networks subnets delete nic-load-balancing-network-subnet --region us-central1 --quiet
gcloud compute networks subnets delete nic-load-balancing-network-subnet --region us-west1 --quiet

# delete the network
gcloud compute networks delete nic-load-balancing-network --quiet

#gcloud compute health-checks delete --region us-west1 hc-http-80
#gcloud compute health-checks delete --region us-central1 hc-http-80

#gcloud compute forwarding-rules delete nic-load-balancing-forwarding-rule-c1 --region us-central1
#gcloud compute forwarding-rules delete nic-load-balancing-forwarding-rule-w1 --region us-west1

#gcloud compute backend-services delete --region=us-west1 nic-load-balancing-backend-service-lb-w1
#gcloud compute backend-services delete --region=us-central1 nic-load-balancing-backend-service-lb-c1
