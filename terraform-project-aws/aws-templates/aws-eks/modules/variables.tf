variable "eks_role_createManually" {
  description = "If the role for eks has been created manually, set this to true"
  type = bool
  default = false
}

variable "cluster_name" {
  default = "ProjecteksCluster"
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
  description = "Security group assigned to the vpc link to access the eks cluster."
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "cluster_instance_type" {
  type = list(string)
  default = [ "t3.medium" ]
}

variable "cluster_desired_size" {
  type = number
  default = 2
}

variable "cluster_max_size" {
  type = number
  default = 3
}

variable "cluster_min_size" {
  type = number
  default = 2
}

variable "cluster_version" {
  type = string
  default = "1.29"
}

variable "create_apigw" {
  type = bool
  default = false
}

variable "create_eks" {
  type = bool
  default = false
}

variable "project_clusterRole_arn" {}

variable "project_nodegroup_role_arn" {}