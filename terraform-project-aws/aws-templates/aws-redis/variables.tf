variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type = list(string)
  default = []
}

variable "security_group_ids" {
  description = "A list of security groups"
  type = list(string)
  default = []
}