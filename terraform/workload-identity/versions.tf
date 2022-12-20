terraform {
  required_version = ">= 1.1.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.90.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.6.0"
    }
  }
}
