variable "identifier" {
  type = string
  default = "project"
  description = "The name of the RDS instance"
}

variable "allocated_storage" {
  description = "The aollocated storage in gigabytes"
  type = number
  default = 10
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (new generation of general purpose SSD) or 'io1' (porivsioned IOPS SSD). The default is 'io1' if iops is specified, 'gp2' if not. If you specify 'io1' or 'gp3,' you must also include a vlue for the 'iops' parameter"
  type = string
  default = "gp2"
}

variable "engine" {
  description = "The type of engine to use"
  type = string
  default = "postgres"
}

variable "engine_version" {
  description = "The engine version to use"
  type = number
  default = 16
}

variable "instance_class" {
  type = string
  default = "db.t4g.xlarge"
}

variable "db_name" {
  type = string
  default = "project"
}

variable "username" {
  type = string
  default = "project"
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. The password provided will not be used if 'manage_master_user_password' is set to true"
  type = string
  default = false
  sensitive = true
}

variable "port" {
  description = "The port of which the DB accepts connections"
  type = number
  default = 5432
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type = list(string)
  default = [] 
}

variable "availablility_zone" {
  description = "The Availability Zone of the RDS instance"
  type = string
  default = "us-east-1"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi availability zones"
  type = bool
  default = false
}

variable "publically_accessible" {
  description = "Is the database instance publically accessible"
  type = bool
  default = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance. Syntax 'ddd:hh24:mi-ddd:hh24:mi' Ex: 'Mon:00:00-Mon:03:00"
  type = string
  default = "Sun:00:00-Sun:03:00"
}

variable "backup_retention_period" {
  description = "How long to retain backups"
  type = number
  default = 7
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if enabled. Ex '09:26-10:16' Must not overlap with maintenance_window"
  type = string
  default = "17:00-19:00"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type = map(string)
  default = {}
}

variable "db_instance_tags" {
  description = "Additonal tags for the DB instance"
  type = map(string)
  default = {}
}

variable "db_subnet_group_tags" {
  description = "Additional tags for DB subnet group"
  type = map(string)
  default = {}
}

variable "create_db_subnet_group" {
  type = bool
  default = true
}

variable "db_subnet_group_name" {
  description = "name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  type = string
  default = null
}

variable "db_subnet_group_use_name_prefix" {
  description = "Determines whether to use 'subnet_group_name' as is or create a unique name beginning with the 'subnet_group_name' as the prefix"
  type = bool
  default = true
}

variable "db_subent_group_description" {
  description = "Description of the DB subnet to create"
  type = string
  default = null
}

variable "subnet_ids" {
  description = "A list of VPC subnet IDs"
  type = list(string)
  default = []
}

variable "create_db_instance" {
  type = bool
  default = true
}

variable "max_allocated_storage" {
  type = number
  default = 0
}