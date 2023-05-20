terraform {
  required_version = ">= 1.0.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }

    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }
}

