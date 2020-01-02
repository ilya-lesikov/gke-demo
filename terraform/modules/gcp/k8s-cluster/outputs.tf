output "project_id" {
  value = module.gke.project_id
}

output "region" {
  value = module.gke.region
}

output "cluster" {
  value = module.gke.name
}

# output "cluster_ca_certificate" {
#   value = module.gke.ca_certificate
# }
