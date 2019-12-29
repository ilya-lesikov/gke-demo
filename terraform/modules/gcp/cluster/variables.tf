variable "project_id" {}
variable "namespace" {}
variable "terraform_sa_fqdn" {}

variable "cluster" {
  default = "cluster-demo"
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

variable "region" {
  default = "europe-west4"
}
