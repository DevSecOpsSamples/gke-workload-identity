provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "provider" {}

data "google_container_cluster" "primary" {
  name     = "sample-cluster-${var.stage}"
  location = var.region
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.primary.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}

module "bucket-api-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name       = "bucket-api-sa"
  namespace  = "bucket-api-ns"
  project_id = var.project_id
  roles      = ["roles/iam.workloadIdentityUser", "roles/storage.objectViewer", "roles/storage.admin", "roles/container.admin"]
}

module "pubsub-api-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name       = "pubsub-api-sa"
  namespace  = "pubsub-api-ns"
  project_id = var.project_id
  roles      = ["roles/iam.workloadIdentityUser", "roles/storage.objectViewer", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/container.admin"]
}
data "terraform_remote_state" "this" {
  backend   = "gcs"
  workspace = var.stage

  config = {
    bucket = var.backend_bucket
    prefix = "gke/${data.google_container_cluster.primary.name}-workload-identity"
  }
}