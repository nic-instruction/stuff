#!/bin/bash


gcloud compute health-checks delete --region us-west1 hc-http-80
gcloud compute health-checks delete --region us-central1 hc-http-80

gcloud compute backend-services delete --region=us-west1 nic-load-balancing-backend-service-lb-w1
gcloud compute backend-services delete --region=us-central1 nic-load-balancing-backend-service-lb-c1
