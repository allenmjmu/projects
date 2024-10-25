variable "eks_role_createdManually" {
  type = bool
  default = true
  description = "Variable indicating whether deployment is enabled"
}

variable "cluster_name" {
  default = "ProjecteksCluster"
  type = string
}