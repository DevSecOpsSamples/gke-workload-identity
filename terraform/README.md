# GKE Terraform

## Overview

## Resources

- Create a GKE cluster and node group
- Create a Kubernetes service account
- Workload Identity

### Installation

- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli)
- [Install kubectl and configure cluster access](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)

### Update Terraform variables

[terraform/terraform.tfvars](terraform.tfvars)

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

### Create Terraform workspaces

```bash
cd terraform

terraform workspace new dev
terraform workspace new stg
terraform workspace select dev
terraform workspace list
```

### Run Terraform

```bash
terraform init

terraform plan

terraform apply
```

### Resources

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

### References

- [container_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster)
- [Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [kubernetes_namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace)
- [workload-identity](https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest/submodules/workload-identity)