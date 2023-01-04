provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "this" {
  name               = format("sample-cluster-%s", var.stage)
  location           = var.region
  enable_autopilot   = true
  initial_node_count = 1
  ip_allocation_policy {
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