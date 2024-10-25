output "vpc_id" {
  value = try(aws_vpc.main[0].id, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value = try(aws_vpc.main[0].cidr_block, null)
}

output "elasticache_subnets" {
  description = "List of IDs of elasticache subnets"
  value = aws_subnet.data[*].id
}

output "eks_security_group_id" {
  description = "ID of the EKS security group"
  value = try(aws_security_group.eks_sg.id, null)
}

output "eks_subnet_ids" {
  description = "List of IDs of EKS subnets"
  value = aws_subnet.eks[*].id 
}