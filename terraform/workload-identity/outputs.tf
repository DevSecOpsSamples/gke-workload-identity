output "project_id" {
  value = var.project_id
}

output "stage" {
  value = var.stage
}

output "kubernetes_cluster_name" {
  value       = data.google_container_cluster.primary.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = data.google_container_cluster.primary.endpoint
  description = "GKE Cluster Host"
}