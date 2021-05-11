#!/bin/bash


gcloud compute health-checks delete --region us-west1 hc-http-80
gcloud compute health-checks delete --region us-central1 hc-http-80
