# Terraform for GKE Workload Identity

## Overview

- Create a GKE cluster and node group
- Create a Kubernetes service account & role binding
- Workload Identity

### Installation

- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
- [Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)

### Update Terraform variables

[terraform/cluster/terraform.tfvars](terraform.tfvars)

```bash
project_id = "<project-id>"
region     = "us-central1"
stage      = "dev"
backend_bucket = ""
```

If you want to use the backend with GCS bucket, set the backend_bucket variable:

```bash
project_id = "<project-id>"
region     = "us-central1"
stage      = "dev"
backend_bucket = "terraform-state"
```

### Create a GKE cluster

- Create Terraform workspaces

```bash
cd terraform/cluster/

terraform workspace new dev
terraform workspace new stg
terraform workspace select dev
terraform workspace list
```

- Run Terraform

```bash
terraform init

terraform plan

terraform apply
```

### Create Service Account & Workload Identity

- Create Terraform workspaces

```bash
cd ../../terraform/workload-identity/

terraform workspace new dev
terraform workspace new stg
terraform workspace select dev
terraform workspace list
```

- Run Terraform

```bash
terraform init

terraform plan

terraform apply
```

### Confirm Resources

```bash
kubectl get namespaces
```

```bash
bucket-api-ns     Active   9m58s
default           Active   31h
kube-node-lease   Active   31h
kube-public       Active   31h
kube-system       Active   31h
pubsub-api-ns     Active   9m58s
```

```bash
gcloud iam service-accounts list | grep api
```

```bash
GCP SA bound to K8S SA your-project-id[bucket-api-sa]    bucket-api-sa@your-project-id.iam.gserviceaccount.com    False
GCP SA bound to K8S SA your-project-id[pubsub-api-sa]    pubsub-api-sa@your-project-id.iam.gserviceaccount.com    False
```

```bash
kubectl get serviceaccount -n bucket-api-ns
kubectl get serviceaccount -n pubsub-api-ns
```

```bash
NAME            SECRETS   AGE
bucket-api-sa   0         18m
default         0         38m
NAME            SECRETS   AGE
default         0         38m
pubsub-api-sa   0         18m
```

```bash
kubectl get all -n bucket-api-ns

kubectl get all -n pubsub-api-ns
```

### Enable Workload Identy

```bash
TBD
```

### Manifest Deployment

**important**: Both the IAM service account and Kubernetes service account have the SAME name when you create it by using "terraform-google-modules/kubernetes-engine/google//modules/workload-identity". Thus we will replace Kubernetes service account from `bucket-api-ksa` to `bucket-api-sa`.

```bash
cd bucket-api

sed -e "s|<project-id>|${PROJECT_ID}|g" bucket-api-template.yaml | sed -e "s|bucket-api-ksa|bucket-api-sa|g" > bucket-api.yaml
cat bucket-api.yaml
kubectl apply -f bucket-api.yaml
```

```bash
cd ../pubsub-api

sed -e "s|<project-id>|${PROJECT_ID}|g" pubsub-api-template.yaml | sed -e "s|pubsub-api-ksa|pubsub-api-sa|g" > pubsub-api.yaml
cat pubsub-api.yaml
kubectl apply -f pubsub-api.yaml
```

### Check the status of service

```bash
kubectl describe service -n bucket-api-ns

kubectl describe service -n pubsub-api-ns
```

### Cleanup

```bash
cd terraform/workload-identity 
terraform destroy

cd ../cluster
terraform destroy
```

### References

- [container_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace)
- [workload-identity](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/workload-identity)
