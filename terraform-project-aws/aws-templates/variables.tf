variable "aws_region" {
  description = "Region in AWS to deploy Project Environment"
  type = string
  default = "us-east-1"
}

variable "create_redis" {
  description = "Controls if Redis should be created"
  type = bool
  default = false
}

variable "create_eks" {
  description = "Controls if EKS should be created"
  type = bool
  default = true
}

variable "create_rds" {
  description = "Controls if RDS should be created"
  type = bool
  default = false
}

variable "rds_password" {
  description = "Password for the master DB user"
  type = string
  default = "false"
  sensitive = true
}

variable "create_apigw" {
  type = bool
  default = false
}

variable "environment" {
  type = string
  default = "dev"
}

variable "create_sqs" {
  type = bool
  default = false
}

### EKS
variable "eks_role_createdManually" {
  description = "If the role for EKS has been created manually set this to true"
  type = bool
  default = true
}

variable "cluster_name" {
  default = "ProjecteksCluster"
  type = string
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
  default = "1.29"
  type = string
}

### ALB Controller
variable "alb-controller-iam_enabled" {
  type = bool
  default = true
  description = "Set to false if the iam policies will be created manually"
}

variable "service_account_name" {
  type = string
  default = "aws-load-balancer-controller"
  description = "ALB controller service account name"
}

variable "namespace" {
  type = string
  default = "kube-system"
  description = "Kubernetes namespace to deply ALB Controller Helm chart"
}