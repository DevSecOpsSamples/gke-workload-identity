#!/bin/bash
set -e

echo "PROJECT_ID: ${PROJECT_ID}"

docker build -t bucket-api . --platform linux/amd64
docker tag bucket-api:latest gcr.io/${PROJECT_ID}/bucket-api:latest
docker push gcr.io/${PROJECT_ID}/bucket-api:latest

kubectl scale deployment bucket-api --replicas=0 -n bucket-api
kubectl scale deployment bucket-api --replicas=3 -n bucket-api
sleep 3
kubectl get pods -n bucket-api