variable "project_id" {}
variable "github_infra_owner" {}
variable "github_infra_reponame" {}
variable "github_microservices_owner" {}
variable "github_microservices_reponame" {}
variable "github_community_cloud_builders_owner" {}
variable "github_community_cloud_builders_reponame" {}
variable "microservices" {
  type = list(string)
}

variable "ssh_dir_path" {
  default = "/root/.ssh"
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
    "cloudkms.googleapis.com",
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
    "roles/compute.viewer",
    "roles/container.clusterAdmin",
    "roles/container.developer",
    "roles/iam.serviceAccountUser",   # to access terraform SA for k8s cluster provisioning
    "roles/compute.networkAdmin",
    "roles/storage.objectViewer",   # for pulling images from GCR
    "roles/monitoring.metricWriter",   # to write metrics
    "roles/cloudkms.cryptoKeyDecrypter",   # decrypt KMS keys
  ]
  type = list(string)
}
