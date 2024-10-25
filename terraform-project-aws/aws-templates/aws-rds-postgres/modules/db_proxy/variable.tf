variable "create" {
  type = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {}
}

##################################
# RDS Proxy
##################################

variable "name" {
  description = "The identifier for the proxy. This name must be unique for all proxies owned by AWS account in the specified AWS region. An identifier must beting with a letter and must contain only ASCII letters, digits, and hyphens; it can't end with a hyphen or contain two consecutive hyphens"
  type = string
  default = "project"
}

variable "auth" {
  description = "Configuration block(s) with authorization mechanisms to connect to the associate instancnes or clusters"
  type = any 
  default = {client_password_auth_type: "POSTGRESQL_MD5", username: "project"}
}

variable "engine_family" {
  description = "The kind of database engine that the proxy will connect to. Valid values are 'MYSQL' or 'POSTGRESQL'"
  type = string
  default = "POSTGRESQL"
}

variable "idle_client_timeout" {
  description = "The number of second that a conneciton to the proxy can be inactive before the proxy disconnects it"
  type = number
  default = 1800
}

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role that the proxy uses to access secrets in AWS Secret Manager"
  type = string
  default = ""
}

variable "vpc_security_group_ids" {
  description = "One of more VPC security group IDs to associate with the new proxy"
  type = list(string)
  default = []
}

variable "vpc_subnet_ids" {
  description = "One of more VPC subnet IDs to associate with the new proxy"
  type = list(string)
  default = [ "database" ]
}

variable "proxy_tags" {
  description = "A map of tags to apply to the RDS Proxy"
  type = map(string)
  default = {}
}

# Proxy Target
variable "target_db_instance" {
  description = "Determines whether DB instance is targeted by proxy"
  type = bool
  default = false
}

variable "db_instance_identifier" {
  type = string
  default = "project-databae"
}

variable "target_db_cluster" {
  description = "Determines whether DB cluster is targeted by the proxy"
  type = bool
  default = false
}

variable "db_cluster_identifier" {
  type = string
  default = ""
}

# Proxy Endpoints
variable "endpoints" {
  description = "Map of DB proxy endpoints to create and their attributes (see 'aws_db_proxy_endpoint')"
  type = any
  default = {}
}

#####################################
# IAM Role
#####################################

variable "create_iam_role" {
  type = bool
  default = true
}

variable "iam_role_name" {
  type = string
  default = ""
}

variable "iam_role_name_prefix" {
  description = "Whether to use the unique name beginning with the specified 'iam_role_name'"
  type = bool
  default = false
}

variable "use_role_name_prefix" {
  type = bool
  default = false
}

variable "iam_role_description" {
  type = string
  default = ""
}

variable "iam_role_path" {
  type = string
  default = null
}

variable "iam_role_force_detach_policies" {
  description = "Specifies to force detaching any policies the role has before destroying it"
  type = bool
  default = true
}

variable "iam_role_max_session_duration" {
  description = "The maximum session duration (in seconds) that you want to set for the specified role"
  type = number
  default = 43200 #12 hours
}

variable "iam_role_permission_boundary" {
  description = "The ARN of the policy that is used to set the permission boundary for the role"
  type = string
  default = null
}

variable "iam_role_tags" {
  type = map(string)
  default = {}
}

# IAM Policy
variable "create_iam_policy" {
  type = bool
  default = true
}

variable "iam_policy_name" {
  description = "The name of the role policy. If omitted, Terraform will assign a random, unique name"
  type = string
  default = ""
}

variable "use_policy_name_prefix" {
  type = bool
  default = false
}

variable "kms_key_arns" {
  description = "List of KMS Key ARNs to allow access to decrypt SecretManager secrets"
  type = list(string)
  default = []
}