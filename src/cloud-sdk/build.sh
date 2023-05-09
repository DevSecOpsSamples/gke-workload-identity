docker build -t cloud-sdk . --platform linux/amd64
docker tag cloud-sdk:latest gcr.io/${PROJECT_ID}/cloud-sdk:latest

gcloud auth configure-docker
docker push gcr.io/${PROJECT_ID}/cloud-sdk:latest