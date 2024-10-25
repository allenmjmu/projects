output "aws_db_subnet_group_id" {
  description = "The db subnet group name"
  value = try(aws_db_subnet_group.main[0].id, null)
}

output "aws_db_subnet_group" {
  description = "The ARN of the db subnet group"
  value = try(aws_db_subnet_group.main[0].arn, null)
}