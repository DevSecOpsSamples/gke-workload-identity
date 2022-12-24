set -e

echo "PROJECT_ID: ${PROJECT_ID}"

docker build -t pubsub-api . --platform linux/amd64
docker tag pubsub-api:latest gcr.io/${PROJECT_ID}/pubsub-api:latest
docker push gcr.io/${PROJECT_ID}/pubsub-api:latest

kubectl scale deployment pubsub-api --replicas=0 -n pubsub-api
kubectl scale deployment pubsub-api --replicas=2 -n pubsub-api
sleep 3
kubectl get pods -n pubsub-api