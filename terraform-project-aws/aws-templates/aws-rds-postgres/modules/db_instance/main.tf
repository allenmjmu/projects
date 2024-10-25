# Ref. https://docs.aws.amazon.com/general/latest/aws-arns-and-namespaces.html#genref-aws-service-namepaces
data "aws_partition" "current" {}

resource "aws_db_instance" "main" {
  count = var.create ? 1 : 0 
  identifier = var.identifier
  
  engine = var.engine 
  engine_version = var.engine_version
  instance_class = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type = var.storage_type

  db_name = var.db_name 
  username = var.username
  password = var.password
  port =    var.port

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name = var.db_subnet_group_name

  availability_zone = var.availability_zone
  multi_az = var.multi_az
  publicly_accessible = var.publicly_accessible
  skip_final_snapshot = true
  maintenance_window = var.maintenance_window 

  backup_retention_period = var.backup_retention_period #7
  backup_window = var.backup_window
  max_allocated_storage = var.max_allocated_storage

  tags = var.tags

  # Note: do not add 'latest_restorable_time' to 'ignore_changes'
  # https://github.com/terraform-aws-modules/terraform-aws-rds-issues/478 
}

resource "random_id" "user-password" {
  byte_length = 8
}