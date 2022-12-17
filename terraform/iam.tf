# resource "google_service_account_iam_member" "main" {
#   service_account_id = var.gcp_sa.name
#   role               = "roles/iam.workloadIdentityUser"
#   member             = local.k8s_sa_gcp_derived_name
# }
