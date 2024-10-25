variable "enabled" {
  type = bool
  default = true
  description = "Indicate if the variables are created."
}

variable "cluster_identity_oidc_issuer" {
  description = "oidc issuer"
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_alb_controller_arn" {}

variable "service_account_name" {
  type = string
  default = "aws-load-balancer-controller"
  description = "ALB Controller service account name"
}

variable "namespace" {
  type = string
  default = "kube-system"
  description = "Kubenetes namespace to deploy ALB Controller Helm chart."
}