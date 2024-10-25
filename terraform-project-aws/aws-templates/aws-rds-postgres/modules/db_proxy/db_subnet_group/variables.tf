variable "create" {
  type = bool
  default = true
}

variable "name" {
  type = string
  default = "database"
}

variable "use_name_prefix" {
  description = "Determines whether to use 'name' as is or create a unique name beginning with 'name' as the specified prefix"
  type = bool
  default = true
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type = list(string)
  default = [  ]
}

variable "tags" {
  type = map(string)
  default = {}
}