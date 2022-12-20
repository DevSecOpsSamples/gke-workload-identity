variable "project_id" {
  description = "project id"
  type        = string
}
variable "region" {
  description = "region"
  type        = string
  default     = "us-central1"
}
variable "stage" {
  description = "stage"
  type        = string
  default     = "local"
}
variable "backend_bucket" {
  description = "backend bucket to save tfstate file"
  type        = string
  default     = ""
}