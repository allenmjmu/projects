#!/bin/bash

echo "echo -------------- Egress ------------"
eigw_id=$(aws ec2 describe-egress-only-internet-gateways --filters Name=tag:Name,Values=Project --query 'EgressOnlyInternetGateways[0].EgressOnlyInternetGatewayId' --output text)
echo "terraform import module.vpc.aws_egress_only_internet_gateway.main[0] $eigw_id"

echo "echo ------------- VPC ------------"
vpc_id=$(aws ec2 describe-vpcs --filters Name=tag:Name,Values=Project --query 'Vpcs[0].VpdId' --output text)
echo "terraform import module.vpc.aws_vpc.main[0] $vpc_id"

echo "echo -------------- SUBNETS -------------"
subnet_name_app_a="Project-app-subnet-us-east-1a"
subnet_name_app_b="Project-app-subnet-us-east-1b"
subnet_name_Data_a="Project-Data-subnet-us-east-1a"
subnet_name_Data_b="Project-Data-subnet-us-east-1b"
subnet_name_EKS_a="Project-EKS-subnet-us-east-1a"
subnet_name_EKS_b="Project-EKS-subnet-us-east-1b"
subnet_name_LB_a="Project-LB-subnet-us-east-1a"
subnet_name_LB_b="Project-LB-subnet-us-east-1b"

subnet_id_app_a=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_app_a" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_app_a"
subnet_id_app_b=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_app_b" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_app_b"

subnet_id_Data_a=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_Data_a" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_Data_a"
subnet_id_Data_b=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_Data_b" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_Data_b"

subnet_id_EKS_a=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_EKS_a" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_EKS_a"
subnet_id_EKS_b=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_EKS_b" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_EKS_b"

subnet_id_LB_a=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_LB_a" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_LB_a"
subnet_id_LB_b=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name_LB_b" --query 'Subnets[*].{ID:SubentId}' --output text)
echo "terraform import module.vpc.aws_subnet.app[0] $subnet_id_LB_b"

echo "echo ----------------- SECURITY GROUP -----------------"
security_group_id=$(aws ec2 describe-security-groups --filter Name=group-name,Values=EKS-security-group --query 'SecurityGroups[0].GroupId' --output text)
echo "terraform import module.vpc.aws_security_group.eks_sg $security_group_id"

echo "echo ---------------- ELASTIC IP'S -----------------"
elastic_ip_a=$(aws ec2 describe-address --filter Name=tag:Name,Values=Project-us-east-1a --query 'Addresses[0].AllocationId' --output text)
elastic_ip_b=$(aws ec2 describe-address --filter Name=tag:Name,Values=Project-us-east-1b --query 'Addresses[0].AllocationId' --output text)
echo "terraform import module.vpc.aws_eip.nat[0] $elastic_ip_a"
echo "terraform import module.vpc.aws_eip.nat[1] $elastic_ip_b"

echo "echo ----------------- INTERNET GATEWAY -----------------"
igw_id=$(aws ec2 describe-internet-gateways --filters Name=tag:Name,Values=Project --query 'InternetGateways[0].InternetGatewayId' --output text)
echo "terraform import module.vpc.aws_internet_gatway.main[0] $igw_id"

echo "echo ----------------- NAT GATEWAY ------------------"
nat_gw_a=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=Project-us-east-1a" --query 'NatGateays[0].NatGatewayId' --output text)
nat_gw_b=$(aws ec2 describe-nat-gateways --filter "Name=tag:Name,Values=Project-us-east-1b" --query 'NatGateays[0].NatGatewayId' --output text)
echo "terraform import module.vpc.aws_nat_gateway.main[0] $nat_gw_a"
echo "terraform import module.vpc.aws_nat_gateway.main[1] $nat_gw_b"

echo "echo -------------- ROUTE TABLES ---------------"
route_table_id_lb=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Project-LB-subnet" --query 'RouteTables[0].RouteTableId' --output text)
echo "terraform import modeule.vpc.aws_route_table.lb[0] $route_table_id_lb"
route_table_id_eksa=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Project-EKS-subnet" --query 'RouteTables[0].RouteTableId' --output text)
echo "terraform import modeule.vpc.aws_route_table.eks[0] $route_table_id_lb"
route_table_id_eksb=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=Project-EKS-subnet" --query 'RouteTables[1].RouteTableId' --output text)
echo "terraform import modeule.vpc.aws_route_table.eks[1] $route_table_id_lb"

echo "echo ----------------------- DEFAULT ROUTES ------------------"
echo "terraform import module.vpc.aws_route.lb_internet_gateway $route_table_id_lb""_\"0.0.0.0/0\""
echo "terraform import module.vpc.aws_route.eks_nat_gateway[0] $route_table_id_eksa""_\"0.0.0.0/0\""
echo "terraform import module.vpc.aws_route.eks_nat_gateway[1] $route_table_id_eksb""_\"0.0.0.0/0\""

echo "echo ---------------- ROUTE TABLE ASSOCIATIONS -------------------"
echo "terraform import module.vpc.aws_route_table_association.app[0] $subnet_id_app_a/$route_table_id_lb"
echo "terraform import module.vpc.aws_route_table_association.app[1] $subnet_id_app_b/$route_table_id_lb"
echo "terraform import module.vpc.aws_route_table_association.data[0] $subnet_id_Data_a/$route_table_id_lb"
echo "terraform import module.vpc.aws_route_table_association.data[1] $subnet_id_Data_b/$route_table_id_lb"
echo "terraform import module.vpc.aws_route_table_association.eks[0] $subnet_id_EKS_a/$route_table_id_eksa"
echo "terraform import module.vpc.aws_route_table_association.eks[1] $subnet_id_EKS_b/$route_table_id_eksb"
echo "terraform import module.vpc.aws_route_table_association.lb[0] $subnet_id_LB_a/$route_table_id_lb"
echo "terraform import module.vpc.aws_route_table_association.lb[1] $subnet_id_LB_b/$route_table_id_lb"

echo "echo -------------------- CIDR BLOCKS -------------------"
vpc_cidr_block=$(aws ec2 describe-vpcs --query "Vpc[0].CidrBlockAssociationSet[?CidrBlock=='100.65.25.0/25'].AccosiationId" --output text)
echo "terrform import module.vpc.aws_vpc_ipv4_cidr_block_association.main[0] $vpc_cidr_block"