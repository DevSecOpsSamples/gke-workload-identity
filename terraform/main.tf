provider "google" {
    project     = var.project_id
    region      = var.region
}

resource "google_container_cluster" "primary" {
  name     = "sample-cluster-${var.stage}"
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${google_container_cluster.primary.name}"
  location   = var.region
  cluster    = google_container_cluster.primary.name
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
    tags         = ["gke-node", google_container_cluster.primary.name]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

module "gke_auth" {
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id           = var.project_id
  cluster_name         = google_container_cluster.primary.name
  location             = google_container_cluster.primary.location
  use_private_endpoint = false
}
provider "kubernetes" {
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
  # config_path = "~/.kube/config"
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
  namespace  =  "bucket-api-ns"
  project_id = var.project_id
  roles      = ["roles/storage.admin"]
  depends_on = [
    kubernetes_namespace.bucket-api-ns
  ]
}

module "pubsub-api-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name       = "pubsub-api-sa"
  namespace  =  "pubsub-api-ns"
  project_id = var.project_id
  roles      = ["roles/pubsub.publisher", "roles/pubsub.subscriber"]
  depends_on = [
    kubernetes_namespace.pubsub-api-ns
  ]
}

data "terraform_remote_state" "this" {
  backend   = "gcs"
  workspace = var.stage

  config = {
    bucket =  var.backend_bucket
    prefix = "gke/${google_container_cluster.primary.name}"
  }
}