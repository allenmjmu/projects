locals {
  create_db_subnet_group = var.create_db_subnet_group
  create_db_instance = var.create_db_instance

  db_subnet_group_name = var.create_db_subnet_group ? module.db_subnet_group.db_subnet_group_id : var.db_subnet_group_name
}

module "db_subnet_group" {
  source = "./modules/db_subnet_group"

  create = local.create_db_subnet_group

  name = coalesce(var.db_subnet_group_name, var.identifier)
  use_name_prefix = var.db_subnet_group_use_name_prefix
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, var.db_subnet_group_tags)
}

module "db_instance" {
  source = "./modules/db_instance"

  create = local.create_db_instance
  identifier = var.identifier

  engine = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type = var.storage_type

  db_name = var.db_name
  username = var.username
  password = var.password
  port = var.port

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name = local.db_subnet_group_name

  maintenance_window = var.maintenance_window

  backup_retention_period = var.backup_retention_period
  backup_window = var.backup_window
  max_allocated_storage = var.max_allocated_storage

  tags = merge(var.tags, var.db_instance_tags)
}