locals {
    stage = "dev"
    region      = "us-central1"
}

provider "google" {
    # project     = vars.project_id
    region      = local.region
}

resource "google_container_cluster" "primary" {
  name     = "sample-cluster-${local.stage}"
  location = local.region
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}"
  location   = local.region
  cluster    = google_container_cluster.primary.name
  node_count = 3

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    labels = {
      stage = local.stage
    }
    preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "${vars.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

module "my-app-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name       = "bucket-api"
  namespace  = "bucket-api"
  # project_id = local.project
  project_id = "moloco-sre"
  roles      = ["roles/pubsub.publisher", "roles/pubsub.subscriber"]
}



# resource "kubernetes_namespace" "prod" {
#   metadata {
#     annotations = {
#       name = "prod-namespace"
#     }

#     labels = {
#       namespace = "prod"
#     }

#     name = "prod"
#   }
# }
data "terraform_remote_state" "backend" {
  backend   = "gcs"
  workspace = local.stage

  config = {
    bucket = "${vars.bucket}"
    prefix = "gke/${google_container_cluster.primary.name}"
  }
}