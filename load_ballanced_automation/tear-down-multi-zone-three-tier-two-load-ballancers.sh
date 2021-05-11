#!/bin/bash
gcloud compute forwarding-rules delete http-cr-rule --global --quiet
gcloud compute addresses delete lb-ipv4-1 --global --quiet
gcloud compute target-http-proxies delete http-lb-proxy --quiet
gcloud compute url-maps delete web-map --quiet
gcloud compute backend-services delete web-map-backend-service --global --quiet
gcloud compute health-checks delete http http-basic-check --global --quiet
gcloud compute instance-groups managed delete nic-load-balancing-ig-wc --zone us-west1-c --quiet
gcloud compute instance-groups managed delete nic-load-balancing-ig-wa  --zone us-west1-a --quiet
gcloud compute instance-groups managed delete nic-load-balancing-ig-cc  --zone us-central1-c --quiet
gcloud compute instance-groups managed delete nic-load-balancing-ig-ca --zone us-central1-a --quiet
gcloud compute instance-templates delete nic-load-balancing-template --quiet

gcloud compute firewall-rules delete fw-allow-health-check --quiet
gcloud compute firewall-rules delete fw-allow-ssh --quiet
gcloud compute firewall-rules delete fw-allow-nic-load-balancing-network-access --quiet

gcloud compute networks delete nic-load-balancing-network --quiet

#gcloud compute health-checks delete --region us-west1 hc-http-80
#gcloud compute health-checks delete --region us-central1 hc-http-80

#gcloud compute forwarding-rules delete nic-load-balancing-forwarding-rule-c1 --region us-central1
#gcloud compute forwarding-rules delete nic-load-balancing-forwarding-rule-w1 --region us-west1

#gcloud compute backend-services delete --region=us-west1 nic-load-balancing-backend-service-lb-w1
#gcloud compute backend-services delete --region=us-central1 nic-load-balancing-backend-service-lb-c1
