#!/bin/bash
set -e

COMPUTE_ZONE="us-central1-a"
CLUSTER_ZONE="us-central1"
SERVICE_ACCOUNT="bucket-api-sa"
PUBSUB_SERVICE_ACCOUNT="pubsub-api-sa"
GCS_BUCKET_NAME="${PROJECT_ID}-bucket-api"

gcloud config set project ${PROJECT_ID}
gcloud config set compute/zone ${COMPUTE_ZONE}

# Step1: Create a GKE cluster

CLUSTER_REGION="us-central1"
gcloud container clusters create-auto sample-cluster-dev --region=${CLUSTER_REGION} --project ${PROJECT_ID}
gcloud container clusters get-credentials sample-cluster-auto-dev --region ${CLUSTER_ZONE} --project ${PROJECT_ID}

# Step2: Create Kubernetes namespace and service account

kubectl create namespace bucket-api-ns
kubectl create namespace pubsub-api-ns

kubectl create serviceaccount --namespace bucket-api-ns bucket-api-ksa
kubectl create serviceaccount --namespace pubsub-api-ns pubsub-api-ksa

# Step3: IAM service account for bucket-api

echo "PROJECT_ID: ${PROJECT_ID}, SERVICE_ACCOUNT: ${SERVICE_ACCOUNT}"

gcloud iam service-accounts create ${SERVICE_ACCOUNT} --display-name="bucket-api-ns service account"
gcloud iam service-accounts list | grep bucket-api-sa

gcloud iam service-accounts add-iam-policy-binding \
       --role roles/iam.workloadIdentityUser \
       --member "serviceAccount:${PROJECT_ID}.svc.id.goog[bucket-api-ns/bucket-api-ksa]" \
       ${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com

kubectl annotate serviceaccount --namespace bucket-api-ns bucket-api-ksa \
        iam.gke.io/gcp-service-account=${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com

echo "GCS_BUCKET_NAME: ${GCS_BUCKET_NAME}"
gcloud storage buckets create gs://${GCS_BUCKET_NAME}

gsutil iam ch serviceAccount:${SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com:objectAdmin \
       gs://${GCS_BUCKET_NAME}/

# Step4: Deploy bucket-api

cd src/bucket-api
docker build -t bucket-api . --platform linux/amd64
docker tag bucket-api:latest gcr.io/${PROJECT_ID}/bucket-api:latest

gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/bucket-api:latest

sed -e "s|<project-id>|${PROJECT_ID}|g" bucket-api-template.yaml > bucket-api.yaml
cat bucket-api.yaml
kubectl apply -f bucket-api.yaml

kubectl describe pods -n bucket-api-ns
kubectl logs -l app=bucket-api -n bucket-api-ns
kubectl describe service -n bucket-api-ns

LB_IP_ADDRESS=$(gcloud compute forwarding-rules list | grep bucket-api | awk '{ print $2 }' | head -n 1)

# It takes several minutes to connect
echo "http://${LB_IP_ADDRESS}/" && curl http://${LB_IP_ADDRESS}/
echo "http://${LB_IP_ADDRESS}/bucket" && curl http://${LB_IP_ADDRESS}/bucket


# Step5: IAM service account for pubsub-api

echo "PROJECT_ID: ${PROJECT_ID}, PUBSUB_SERVICE_ACCOUNT: ${PUBSUB_SERVICE_ACCOUNT}"

gcloud iam service-accounts create ${PUBSUB_SERVICE_ACCOUNT} --display-name="pubsub-api-ns service account"
gcloud iam service-accounts list | grep pubsub-api

gcloud iam service-accounts add-iam-policy-binding \
       --role roles/iam.workloadIdentityUser \
       --member "serviceAccount:${PROJECT_ID}.svc.id.goog[pubsub-api-ns/pubsub-api-ksa]" \
       ${PUBSUB_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com

kubectl annotate serviceaccount --namespace pubsub-api-ns pubsub-api-ksa \
        iam.gke.io/gcp-service-account=${PUBSUB_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com

# Step6: Create a Topic/Subscription and grant a permission

gcloud services enable cloudresourcemanager.googleapis.com pubsub.googleapis.com \
       container.googleapis.com
gcloud pubsub topics create echo
gcloud pubsub subscriptions create echo-read --topic=echo

echo "PUBSUB_SERVICE_ACCOUNT: ${PUBSUB_SERVICE_ACCOUNT}"
gcloud pubsub topics add-iam-policy-binding echo  \
      --member=serviceAccount:${PUBSUB_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com \
      --role=roles/pubsub.publisher

gcloud pubsub topics get-iam-policy echo --format yaml

gcloud pubsub subscriptions add-iam-policy-binding echo-read \
       --member=serviceAccount:${PUBSUB_SERVICE_ACCOUNT}@${PROJECT_ID}.iam.gserviceaccount.com  \
       --role=roles/pubsub.subscriber

gcloud pubsub subscriptions get-iam-policy projects/${PROJECT_ID}/subscriptions/echo-read \
       --format yaml

# Step7: Deploy pubsub-api

cd ../pubsub-api
docker build -t pubsub-api . --platform linux/amd64
docker tag pubsub-api:latest gcr.io/${PROJECT_ID}/pubsub-api:latest

gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/pubsub-api:latest

sed -e "s|<project-id>|${PROJECT_ID}|g" pubsub-api-template.yaml > pubsub-api.yaml
cat pubsub-api.yaml
kubectl apply -f pubsub-api.yaml -n pubsub-api-ns

kubectl describe pods -n pubsub-api-ns
kubectl logs -l app=pubsub-api -n pubsub-api-ns
#kubectl get service -n pubsub-api-ns -o yaml
kubectl describe service -n pubsub-api-ns

LB_IP_ADDRESS=$(gcloud compute forwarding-rules list | grep pubsub-api | awk '{ print $2 }' | head -n 1)
echo ${LB_IP_ADDRESS}

# It takes several minutes to connect
curl http://${LB_IP_ADDRESS}/pub
curl http://${LB_IP_ADDRESS}/sub
curl http://${LB_IP_ADDRESS}/bucket

