variable "project_id" {}
variable "region" {}
variable "cluster" {}

variable "namespace" {
  default = "main"
}

variable "argocd_ver" {
  default = "1.3.6"
}

variable "argo_rollouts_ver" {
  default = "0.6.2"
}
