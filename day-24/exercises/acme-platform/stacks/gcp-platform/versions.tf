terraform {
  required_version = ">= 1.9"

  # For this bootcamp repo, the GCS backend bucket is created manually because
  # it is only a single resource. If the backend setup grows beyond a small
  # number of resourcete Terraform s, move it into a separabootstrap stack.
  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
  }
}
