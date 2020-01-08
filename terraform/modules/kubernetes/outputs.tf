output "github_infra_owner" {
  var.github_infra_owner
}
output "github_infra_reponame" {}
output "project_id" {}
output "k8s_cluster_url" {}
output "app_namespace" {}

output "context" {
  value = local.context
}
