variable "cluster" {
  default = "cluster-demo"
}

variable "services" {
  default = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containerregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudbilling.googleapis.com",
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
  ]
  type = list(string)
}

variable "cloudbuild_sa_roles" {
  default = [
    "roles/container.developer"
  ]
  type = list(string)
}

variable "net_name" {
  default = "net-demo"
}

variable "subnet_name" {
  default = "subnet-demo"
}

variable "subnet_primary_ip_range" {
  default = "10.0.0.0/17"
}

variable "subnet_pods_ip_range_name" {
  default = "ip-range-pods"
}

variable "subnet_pods_ip_range" {
  default = "192.168.0.0/18"
}

variable "subnet_services_ip_range_name" {
  default = "ip-range-services"
}

variable "subnet_services_ip_range" {
  default = "192.168.64.0/18"
}

variable "project_id" {
}

variable "region" {
  default = "europe-west4"
}

variable "namespace_prod" {
  default = "prod"
}

variable "namespace_staging" {
  default = "staging"
}
