provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "provider" {}

locals {
  is_autopilot_cluster = true
}
data "google_container_cluster" "this" {
  name = local.is_autopilot_cluster ? "sample-cluster-${var.stage}" : "sample-cluster-standard-${var.stage}"
  # var.region = is_autopilot_cluster ? "us-central1" : "us-central1-a"
  location = var.region
}

module "gke_auth" {
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id           = var.project_id
  cluster_name         = data.google_container_cluster.this.name
  location             = data.google_container_cluster.this.location
  use_private_endpoint = false
}

provider "kubernetes" {
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
}

resource "kubernetes_namespace" "bucket-api-ns" {
  metadata {
    name = "bucket-api-ns"
  }
  timeouts {
    delete = "30m"
  }
}

resource "kubernetes_namespace" "pubsub-api-ns" {
  metadata {
    name = "pubsub-api-ns"
  }
  timeouts {
    delete = "30m"
  }
}

module "bucket-api-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name       = "bucket-api-sa"
  namespace  = "bucket-api-ns"
  project_id = var.project_id
  roles      = ["roles/iam.workloadIdentityUser", "roles/storage.objectViewer", "roles/storage.admin", "roles/container.admin"]
  depends_on = [kubernetes_namespace.bucket-api-ns]
}
module "pubsub-api-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name       = "pubsub-api-sa"
  namespace  = "pubsub-api-ns"
  project_id = var.project_id
  roles      = ["roles/iam.workloadIdentityUser", "roles/storage.objectViewer", "roles/pubsub.publisher", "roles/pubsub.subscriber", "roles/container.admin"]
  depends_on = [kubernetes_namespace.pubsub-api-ns]
}
data "terraform_remote_state" "this" {
  backend   = "gcs"
  workspace = var.stage

  config = {
    bucket = var.backend_bucket
    prefix = "gke/${data.google_container_cluster.this.name}-workload-identity"
  }
}