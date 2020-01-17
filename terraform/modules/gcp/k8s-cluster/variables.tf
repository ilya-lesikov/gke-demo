variable "project_id"               {}
variable "region"                   {}
variable "zones"                    {
  type = list(string)
}
variable "machine_type"             {}
variable "max_nodes"                {}
variable "terraform_sa_fqdn"        {}
variable "environment"              {}
variable "master_cidr"              {}
variable "subnet_primary_ip_range"  {}
variable "subnet_pods_ip_range"     {}
variable "subnet_services_ip_range" {}
