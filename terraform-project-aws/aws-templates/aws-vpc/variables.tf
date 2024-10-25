#################################
# VPC
#################################

variable "create_vpc" {
  type = bool
  default = true
}

variable "name" {
  type = string
  default = "Project"
}

variable "cidr" {
  description = "(Optional) the IPv4 CDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using 'ipv4_netmask_length' & 'ipv4_ipam_pool_id"
  type = string
  default = "172.30.37.0/24"
}

variable "secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks to associate with the VPC to extend the IP Address pool"
  type = list(string)
  default = [ "100.65.25.0/25" ]
}

variable "azs" {
  description = "A list of availibility zone names or ids in the region"
  type = list(string)
  default = [ "us-east-1a","us-east-1b" ]
}

variable "vpc_tags" {
  description = "Additional tags for the VPC"
  type = map(string)
  default = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type = map(string)
  default = {}
}

##################################
# LB Subnets
##################################

variable "lb_subnets" {
  description = "A list of lb subnets inside the VPC"
  type = list(string)
  default = [ "172.30.37.0/27", "172.30.37.32/27" ]
}

variable "lb_subnet_names" {
  description = "Explicit values to use in the name tag on lb subnets. If empty, name tags are generated"
  type = list(string)
  default = []
}

variable "lb_subnet_suffix" {
  description = "Suffix to append to LB subnet names"
  type = string
  default = "LB-subnet"
}

variable "lb_subnet_tags" {
  description = "Additional tags for the LB subnets"
  type = map(string)
  default = {
    "kubernetes.io/role/interal-elb" = "1"
  }
}

variable "lb_subnet_tags_per_az" {
  description = "Additional tags for the lb subnets where the primary key is the AZ"
  type = map(map(string))
  default = {}
}

variable "lb_route_table_tags" {
  description = "Additional tags for the LB route tables"
  type = map(string)
  default = {}
}

################################
# LB Network ACLs
################################

variable "lb_dedicated_network_acl" {
  description = "Whether to use dedicated newtork ACL (not default) and custom rules for LB subnets"
  type = bool
  default = false
}

variable "lb_inbound_acl_rules" {
  description = "LB subnets inboud network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },
  ]
}

variable "lb_outbound_acl_rules" {
  description = "LB subnets outbound network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },  
  ]
}

variable "lb_acl_tags" {
  description = "Additonal tags for the LB subnets network ACL"
  type = map(string)
  default = {}
}

###################################
# App Subnets
###################################

variable "app_subnet_names" {
  description = "Explicit values to use in the name tag on app subnets. If empty, name tags are generated"
  type = list(string)
  default = []
}

variable "app_subnets" {
  description = "A list of app subnets inside the VPC"
  type = list(string)
  default = [ "172.30.37.64/28","172.30.37.80/28" ]
}

variable "app_subnet_suffix" {
  description = "Suffix to append to app subnets name"
  type = string
  default = "app-subnet"
}

variable "app_subnet_tags" {
  description = "Additional tags for the private subnets"
  type = map(string)
  default = {}
}

variable "app_subnet_tags_per_az" {
  description = "Addional tags for the private subnets where the primary key is the AZ"
  type = map(map(string))
  default = {}
}

variable "app_route_table_tags" {
  description = "Additional tags for the private route tables"
  type = map(string)
  default = {}
}

####################################
# App Network ACLs
####################################

variable "app_dedicated_network_acl" {
  description = "Whether to used dedicated network ACL (not default) and custom rules for private subnets"
  type = bool
  default = false
}

variable "app_inbound_acl_rules" {
  description = "App subnets inboud network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },
  ]
}

variable "app_outbound_acl_rules" {
  description = "App subnets outbound network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },  
  ]
}

variable "app_acl_tags" {
  description = "Additonal tags for the App subnets network ACL"
  type = map(string)
  default = {}
}

############################### 
# Data Subnets
###############################

variable "data_subnet_names" {
  description = "Explicit values to use in the name tag on data subnets. If empty, name tags are generated"
  type = list(string)
  default = []
}

variable "data_subnets" {
  description = "A list of data subnets inside the VPC"
  type = list(string)
  default = [ "172.30.37.96/28","172.30.37.112/28" ]
}

variable "data_subnet_suffix" {
  description = "Suffix to append to data subnets name"
  type = string
  default = "Data-subnet"
}

variable "data_subnet_tags" {
  description = "Additional tags for the data subnets"
  type = map(string)
  default = {}
}

variable "data_subnet_tags_per_az" {
  description = "Addional tags for the data subnets where the primary key is the AZ"
  type = map(map(string))
  default = {}
}

variable "data_route_table_tags" {
  description = "Additional tags for the data route tables"
  type = map(string)
  default = {}
}

################################
# Data network ACLs
################################

variable "data_dedicated_network_acl" {
  description = "Whether to used dedicated network ACL (not default) and custom rules for data subnets"
  type = bool
  default = false
}

variable "data_inbound_acl_rules" {
  description = "Data subnets inboud network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },
  ]
}

variable "data_outbound_acl_rules" {
  description = "Data subnets outbound network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },  
  ]
}

variable "data_acl_tags" {
  description = "Additonal tags for the data subnets network ACL"
  type = map(string)
  default = {}
}

#######################################
# EKS Subnets
#######################################

variable "eks_subnet_names" {
  description = "Explicit values to use in the name tag on eks subnets. If empty, name tags are generated"
  type = list(string)
  default = []
}

variable "eks_subnets" {
  description = "A list of eks subnets inside the VPC"
  type = list(string)
  default = [ "100.65.25.0/26","100.65.25.64/26" ]
}

variable "eks_subnet_suffix" {
  description = "Suffix to append to eks subnets name"
  type = string
  default = "EKS-subnet"
}

variable "eks_subnet_tags" {
  description = "Additional tags for the eks subnets"
  type = map(string)
  default = {}
}

variable "eks_subnet_tags_per_az" {
  description = "Addional tags for the eks subnets where the primary key is the AZ"
  type = map(map(string))
  default = {}
}

variable "eks_route_table_tags" {
  description = "Additional tags for the eks route tables"
  type = map(string)
  default = {}
}

################################
# EKS network ACLs
################################

variable "eks_dedicated_network_acl" {
  description = "Whether to used dedicated network ACL (not default) and custom rules for eks subnets"
  type = bool
  default = false
}

variable "eks_inbound_acl_rules" {
  description = "EKS subnets inboud network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },
  ]
}

variable "eks_outbound_acl_rules" {
  description = "EKS subnets outbound network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },  
  ]
}

variable "eks_acl_tags" {
  description = "Additonal tags for the eks subnets network ACL"
  type = map(string)
  default = {}
}

#######################################
# Elasticache Subnets
#######################################

variable "elasticache_subnet_names" {
  description = "Explicit values to use in the name tag on elasticache subnets. If empty, name tags are generated"
  type = list(string)
  default = ["elasticache"]
}

variable "elasticache_subnets" {
  description = "A list of elasticache subnets inside the VPC"
  type = list(string)
  default = [ "" ]
}

variable "elasticache_subnet_suffix" {
  description = "Suffix to append to elasticache subnets name"
  type = string
  default = "elasticache-subnet"
}

variable "elasticache_subnet_tags" {
  description = "Additional tags for the elasticache subnets"
  type = map(string)
  default = {}
}

variable "creat_elasticache_subnet_route_table" {
  description = "Controls if separate route table for elasticache should be created"
  type = bool
  default = false
}

variable "elasticache_route_table_tags" {
  description = "Additional tags for the elasticache route tables"
  type = map(string)
  default = {}
}

################################
# Elasticache network ACLs
################################

variable "elasticache_dedicated_network_acl" {
  description = "Whether to used dedicated network ACL (not default) and custom rules for elasticache subnets"
  type = bool
  default = false
}

variable "elasticache_inbound_acl_rules" {
  description = "elasticache subnets inboud network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },
  ]
}

variable "elasticache_outbound_acl_rules" {
  description = "elasticache subnets outbound network ACLs"
  type = list(map(string))
  default = [ 
    {
        rule_number = 100
        rule_action = "allow"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_block = "0.0.0.0/0"
    },  
  ]
}

variable "elasticache_acl_tags" {
  description = "Additonal tags for the elasticache subnets network ACL"
  type = map(string)
  default = {}
}

###############################
# Internet Gateway
###############################

variable "create_igw" {
  type = bool
  default = true
}

variable "create_egress_only_igw" {
  type = bool
  default = true
}

variable "igw_tags" {
  description = "Additional tags for the internet gateway"
  type = map(string)
  default = {}
}

##################################
# NAT Gateway
##################################

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type = bool
  default = true
}

variable "nat_gateway_destination_cidr_block" {
  description = "Used to pass a custom destination route for private NAT Gateways. If not specified, the default 0.0.0.0/0 is used as a destination route"
  type = string
  default = "0.0.0.0/0"
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private subnets"
  type = bool
  default = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires 'var.azs' to be set, and the number of 'lb_subnets' created to be greater than or equal to the number of availabililty zones specified in 'var.azs.'"
  type = bool
  default = true
}

variable "reuse_nat_ips" {
  description = "Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'external_nat_ip_ids' variable"
  type = bool
  default = false
}

variable "external_nat_ip_ids" {
  description = "List of EIP IDs to be assigned to the NAT gateways (used in combination with reuse_nat_ips)"
  type = list(string)
  default = []
}

variable "external_nat_ips" {
  description = "List of EIPs to be used for 'nat_public_ips' output (used in combination with reuse_nat_ips and external_nat_ip_ids)"
  type = list(string)
  default = []
}

variable "nat_gatway_tags" {
  description = "Additional tags for the NAT gateways"
  type = map(string)
  default = {}
}

variable "nat_eip_tags" {
  description = "Additional tags for the NAT EIP"
  type = map(string)
  default = {}
}