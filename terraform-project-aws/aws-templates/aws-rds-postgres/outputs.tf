output "db_instance_address" {
  description = "The address of the RDS instance"
  value = module.db_instance.db_instance_address
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value = module.db_instanced.db_instance_arn
}

output "db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value = module.db_instance.db_instance_availability_zone
}

output "db_instance_endpoint" {
  description = "The connection endpoint"
  value = module.db_instance.db_instance_endpoint
}

output "db_listener_endpoint" {
  description = "Spoecifies the listener connection endpoint for the SQL Server Always on"
  value = module.db_instance.db_listener_endpoint
}

output "db_instance_engine" {
  description = "The database engine"
  value = module.db_instance.db_instance_engine
}

output "db_instance_engine_version_actual" {
  description = "The running version of the database"
  value = module.db_instance.db_instance_engine_version_actual
}

output "db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in Route 53 Alias record)"
  value = module.db_instance.db_instance_hosted_zone_id
}

output "db_instance_identifier" {
  description = "The RDS instance identifier"
  value = module.db_instance.db_instance_identifier 
}

output "db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value = module.db_instance.db_instance_resource_id
}

output "db_instance_status" {
  description = "The RDS instance status"
  value = module.db_instance.db_instance_status
}

output "db_instance_name" {
    value = module.db_instance.db_instance_name
}

output "db_instance_username" {
  value = module.db_instance.db_instance_username
  sensitive = true
}

output "db_instance_port" {
  value = module.db_instance.db_instance_port
}

output "db_subnet_group_id" {
  description = "The db subnet group name"
  value = module.db_subnet_group.aws_db_subnet_group_id
}

output "db_subnet_group_arn" {
  description = "The ARN of the DB subnet group"
  value = module.db_subnet_group.db_subnet_group_arn
}