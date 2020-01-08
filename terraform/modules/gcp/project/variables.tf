variable "project_id" {}
variable "github_microservices_owner" {}
variable "github_microservices_reponame" {}
variable "github_community_cloud_builders_owner" {}
variable "github_community_cloud_builders_reponame" {}
variable "microservices" {
  type = list(string)
}

variable "services" {
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudbilling.googleapis.com",
    "dns.googleapis.com",   # for pulling images from GCR from private cluster
  ]
  type = list(string)
}

variable "terraform_sa_roles" {
  default = [
    "roles/compute.viewer",
    "roles/container.clusterAdmin",
    "roles/container.developer",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/compute.networkAdmin",
    "roles/storage.objectViewer",   # for pulling images from GCR
    "roles/monitoring.metricWriter",   # to write metrics
  ]
  type = list(string)
}

variable "cloudbuild_sa_roles" {
  default = [
    "roles/container.developer"
  ]
  type = list(string)
}
