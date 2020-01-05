variable "project_id" {}
variable "region" {}
variable "zones" {
  type = list(string)
}
variable "machine_type" {}
variable "max_nodes" {}
variable "terraform_sa_fqdn" {}
variable "environment" {}
variable "master_cidr" {}
variable "subnet_primary_ip_range" {}
variable "subnet_pods_ip_range" {}
variable "subnet_services_ip_range" {}

  # default = "10.0.0.0/17"

# variable "subnet_pods_ip_range_name" {
#   default = "ip-range-pods"
# }

  # default = "192.168.0.0/18"

# variable "subnet_services_ip_range_name" {
#   default = "ip-range-services"
# }

#   default = "192.168.64.0/18"
