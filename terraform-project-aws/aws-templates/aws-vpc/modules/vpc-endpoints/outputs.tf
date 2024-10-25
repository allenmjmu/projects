output "endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value = aws_vpc_endpoint.main
}

############################################
# Security Group
############################################

output "security_group_arn" {
  description = "ARN of the security group"
  value = try(aws_security_group.main[0].arn, null)
}

output "security_group_id" {
  value = try(aws_security_group.main[0].id, null)
}