variable "project_id"            {}
variable "region"                {}
variable "zones"                 {
  type = list(string)
}
variable "cluster"               {}
variable "environment"           {}
variable "endpoint"              {}
variable "github_demo_owner"     {}
variable "github_demo_reponame"  {}
variable "argocd_ver"            {}
variable "argo_rollouts_ver"     {}
variable "hipstershop_namespace" {}

variable "management_context" {
  default = null    # If "null" then use regular local.context
}

variable "argocd_install" {
  default = false
}

variable "argocd_manager_install" {
  default = false
}

variable "argo_rollouts_install" {
  default = false
}
