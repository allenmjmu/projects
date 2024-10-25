variable "create" {
  type = bool
  default = true
}

variable "vpc_id" {
  description = "The ID of the VPC in which the endpoint will be used"
  type = string
  default = null
}

variable "endpoints" {
  description = "A map of interface and/or gateway endpoints containing their properties and configurations"
  type = any
  default = {}
}

variable "security_group_ids" {
  description = "Defualt security group IDs to associate with the VPC endpoints"
  type = list(string)
  default = []
}

variable "subnet_ids" {
  description = "Default subnet IDs to associate with the VPC endpoints"
  type = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updateing, and deleting VPC endpoint resources"
  type = map(string)
  default = {}
}

#########################################
# Security Group
#########################################

variable "create_security_group" {
  type = bool
  default = false
}

variable "security_group_name" {
  description = "Name to use on security group created. Conflicts with 'security_group_name_prefix'"
  type = string
  default = null
}

variable "security_group_name_prefix" {
  description = "Name to use on security group created. Conflicts with 'security_group_name'"
  type = string
  default = null
}

variable "security_group_description" {
  type = string
  default = null
}

variable "security_group_rules" {
  description = "Security group fules to add to the security group created"
  type = any
  default = {}
}

variable "security_group_tags" {
  type = map(string)
  default = {}
}