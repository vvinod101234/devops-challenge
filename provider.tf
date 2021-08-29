# Specify the GCP Provider
provider "google" {
  project = var.project_id
  region  = var.region
  credentials = file("recruitment-323813-1d0b7be6e570.json")
}