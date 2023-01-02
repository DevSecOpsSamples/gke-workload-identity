provider "google" {
  project = var.project_id
  region  = var.region
}
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# locals {
#   identity_namespace = ["bucket-api-ns", "pubsub-api-ns"]
# }

# https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/guides/version_4_upgrade
resource "google_container_cluster" "this" {
  # provider                 = google-beta
  name                     = format("sample-cluster-standard-%s", var.stage)
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  # private_cluster_config {
  #   enable_private_nodes    = true
  #   enable_private_endpoint = false
  # }
  workload_identity_config {
    workload_pool = format("%s.svc.id.goog", var.project_id)
  }
}

resource "google_container_node_pool" "nodes" {
  name       = google_container_cluster.this.name
  location   = var.region
  cluster    = google_container_cluster.this.name
  node_count = 3

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    labels = {
      stage = var.stage
    }
    preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", google_container_cluster.this.name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

data "terraform_remote_state" "this" {
  backend   = "gcs"
  workspace = var.stage
  config = {
    bucket = var.backend_bucket
    prefix = format("gke/%s", google_container_cluster.this.name)
  }
}