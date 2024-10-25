variable "create" {
  description = "Whether to create this resource or not"
  type = bool
  default = true
}

variable "identifier" {
  description = "The name of the RDS instance"
  type = string
  default = "project"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type = number
  default = 10
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), 'gp3' (new generation of general purpose SSD), or 'io1' (provisioned IOPS SSD) the default is 'io1' if iops is specified, gp2 if not. If you specify 'io1' or 'gp3,' you must also include a value for the 'iops' parameter"
  type = string
  default = "gp2"
}

variable "engine" {
  description = "(Required) The database engine to use"
  type = string
  default = "PostgreSQL"
}

variable "engine_version" {
  description = "The engine version to use"
  type = number
  default = 16
}

variable "instance_class" {
  description = "The instance type of the RDS instance. db.t4g.xlarge - 4vCPU, 16GB memory, Burst up to 2780 Mbps, Up to 5 Gbps network performance"
  type = string
  default = "db.t4g.xlarge"
}

variable "db_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type = string
  default = "project-database"
}

variable "username" {
  description = "Username for the master DB user"
  type = string
  default = "project"
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  type = string
  default = ""
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type = number
  default = 5432
}

variable "vpc_security_group_ids" {
  description = "List of BPC security groups to associate"
  type = list(string)
  default = []
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB nstance will be created in the VPC associate with the DB subnet group. If unspecified, will be created in the default VPC."
  type = string
  default = "database"
}

variable "availability_zone" {
  description = "The Availability Zone of the RDS instance"
  type = string
  default = "us-east-1"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type = bool
  default = true
}

variable "publicly_accessible" {
  type = bool
  default = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' Eg: 'Mon:00:00-Mon:00:00"
  type = string
  default = "Sun:00:00-Sun:03:00"
}

variable "backup_retention_period" {
  description = "Numbe of days to retain backups"
  type = number
  default = 7
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are create if they are enables. Ex: '09:46-10:16' Must not overlap with maintenance window"
  type = string
  default = null
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type = map(string)
  default = {}
}

variable "max_allocated_storage" {
  description = "Specifies the value for storage autoscaling"
  type = number
  default = 0
}