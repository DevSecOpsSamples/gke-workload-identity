provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "this" {
  name                     = "sample-cluster-${var.stage}"
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
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
    prefix = "gke/${google_container_cluster.this.name}"
  }
}