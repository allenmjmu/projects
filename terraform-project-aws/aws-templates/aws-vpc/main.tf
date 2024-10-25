locals {
  len_lb_subnets = max(length(var.lb_subnets))
  len_app_subnets = max(length(var.app_subnets))
  len_data_subnets = max(length(var.data_subnets))
  len_eks_subnets = max(length(var.eks_subnets))
  len_elasticache_subnets = max(length(var.elasticache_subnets))

  max_subnet_length = max(
    local.len_app_subnets,
    local.len_lb_subnets,
    local.len_data_subnets,
    local.len_eks_subnets,
    local.len_elasticache_subnets,
  )

  # Use 'local.vpc_id' to give a hint to Terraofrm that subnets should be dleted before secondary CIDR blocks can be free!
  vpc_id = try(aws_vpc_ipv4_cidr_block_association.main[0].vpc_id, aws_vpc.main[0].id, "")

  create_vpc = var.create_vpc
}

#########################################
# VPC
#########################################

resource "aws_vpc" "main" {
  count = local.create_vpc ? 1 : 0

  cidr_block = var.cidr
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}

/* Not sure if below resource is needed. Can be used for BYOIP (Bring Your Own IP) */
resource "aws_vpc_ipv4_cidr_block_association" "main" {
  count = local.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  #Do not turn main into 'local.vpc_id'
  vpc_id = aws_vpc.main[0].id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

######################################
# Load Balancer Subnets
######################################

locals {
  create_lb_subnets = local.create_vpc && local.len_lb_subnets > 0
}

resource "aws_subnet" "lb" {
  count = local.create_lb_subnets && (!var.one_nat_gateway_per_az || local.len_lb_subnets >= length(var.azs)) ? local.len_lb_subnets : 0

  cidr_block = element(concat(var.lb_subnets, [""]), count.index)
  vpc_id = local.vpc_id

  tags = merge(
    {
        Name = try(
            var.lb_subnet_names[count.index],
            format("${var.name}-${var.lb_subnet_suffix}-%s", element(var.azs, count.index))
        )
    },
    var.tags,
    var.lb_subnet_tags,
    lookup(var.lb_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

resource "aws_route_table" "lb" {
  count = local.create_lb_subnets ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${var.name}-${var.lb_subnet_suffix}" },
    var.tags,
    var.lb_route_table_tags,
  )
}

resource "aws_route_table_association" "lb" {
  count = local.create_lb_subnets ? local.len_lb_subnets : 0

  subnet_id = element(aws_subnet.lb[*].id, count.index)
  route_table_id = aws_route_table.lb[0].id
}

resource "aws_route_table_association" "data" {
  count = local.create_lb_subnets ? local.len_lb_subnets : 0

  subnet_id = element(aws_subnet.lb[*].id, count.index)
  route_table_id = aws_route_table.lb[0].id  
}

resource "aws_route_table_association" "app" {
  count = local.create_lb_subnets ? local.len_lb_subnets : 0

  subnet_id = element(aws_subnet.lb[*].id, count.index)
  route_table_id = aws_route_table.lb[0].id  
}

resource "aws_route" "lb_internet_gateway" {
  route_table_id = aws_route_table.lb[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main[0].id

  timeouts {
    create = "5m"
  }
}

#########################################
# LB Network ACLs
#########################################

resource "aws_network_acl" "lb" {
  count = local.create_lb_subnets && var.lb_dedicated_network_acl ? 1 : 0

  vpc_id = local.vpc_id
  subnet_ids = aws_subnet.lb[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.lb_subnet_suffix}" },
    var.tags,
    var.lb_acl_tags,
  )
}

resource "aws_network_acl_rule" "lb_inbound" {
  count = local.create_lb_subnets && var.lb_dedicated_network_acl ? length(var.lb_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.lb[0].id

  /* allow all inbound */
  egress = false
  rule_number = var.lb_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.lb_inbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.lb_inbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.lb_inbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.lb_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.lb_inbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.lb_inbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.lb_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "lb_outbound" {
  count = local.create_lb_subnets && var.lb_dedicated_network_acl ? length(var.lb_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.lb[0].id

  /* allow all inbound */
  egress = false
  rule_number = var.lb_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.lb_outbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.lb_outbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.lb_outbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.lb_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.lb_outbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.lb_outbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.lb_outbound_acl_rules[count.index], "cidr_block", null)
}

########################################
# App Subnets
########################################

locals {
  create_app_subnets = local.create_vpc && local.len_app_subnets > 0
}

resource "aws_subnet" "app" {
  count = local.create_app_subnets ? local.len_app_subnets : 0

  cidr_block = element(concat(var.app_subnets, [""]), count.index)
  vpc_id = local.vpc_id

  tags = merge(
    {
        Name = try(
            var.app_subnet_names[count.index],
            format("${var.name}-${var.app_subnet_suffix}-%s", element(var.azs, count.index))
        )
    },
    var.tags,
    var.app_subnet_tags,
    lookup(var.app_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

######################################
# App Network ACLs
######################################

locals {
  create_app_network_acl = local.create_app_subnets && var.app_dedicated_network_acl
}

resource "aws_network_acl" "app" {
  count = local.create_app_network_acl ? 1 : 0

  vpc_id = local.vpc_id
  subnet_ids = aws_subnet.app[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.app_subnet_suffix}" },
    var.tags,
    var.app_acl_tags,
  )
}

resource "aws_network_acl_rule" "app_inbound" {
  count = local.create_app_network_acl ? length(var.app_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.app[0].id

  /* allow all inbound */
  egress = false
  rule_number = var.app_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.app_inbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.app_inbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.app_inbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.app_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.app_inbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.app_inbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.app_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "app_outbound" {
  count = local.create_app_network_acl ? length(var.app_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.app[0].id

  /* allow all inbound */
  egress = true
  rule_number = var.app_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.app_outbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.app_outbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.app_outbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.app_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.app_outbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.app_outbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.app_outbound_acl_rules[count.index], "cidr_block", null)
}

########################################
# Data Subnets
########################################

locals {
  create_data_subnets = local.create_vpc && local.len_data_subnets > 0
}

resource "aws_subnet" "data" {
  count = local.create_data_subnets ? local.len_data_subnets : 0

  cidr_block = element(concat(var.data_subnets, [""]), count.index)
  vpc_id = local.vpc_id

  tags = merge(
    {
        Name = try(
            var.data_subnet_names[count.index],
            format("${var.name}-${var.data_subnet_suffix}-%s", element(var.azs, count.index))
        )
    },
    var.tags,
    var.data_subnet_tags,
    lookup(var.data_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

######################################
# Data Network ACLs
######################################

locals {
  create_data_network_acl = local.create_data_subnets && var.data_dedicated_network_acl
}

resource "aws_network_acl" "data" {
  count = local.create_data_network_acl ? 1 : 0

  vpc_id = local.vpc_id
  subnet_ids = aws_subnet.data[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.data_subnet_suffix}" },
    var.tags,
    var.data_acl_tags,
  )
}

resource "aws_network_acl_rule" "data_inbound" {
  count = local.create_data_network_acl ? length(var.data_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.data[0].id

  /* allow all inbound */
  egress = false
  rule_number = var.data_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.data_inbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.data_inbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.data_inbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.data_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.data_inbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.data_inbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.data_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "data_outbound" {
  count = local.create_data_network_acl ? length(var.data_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.data[0].id

  /* allow all inbound */
  egress = true
  rule_number = var.data_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.data_outbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.data_outbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.data_outbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.data_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.data_outbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.data_outbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.data_outbound_acl_rules[count.index], "cidr_block", null)
}

########################################
# EKS Subnets
########################################

locals {
  create_eks_subnets = local.create_vpc && local.len_eks_subnets > 0
}

resource "aws_subnet" "eks" {
  count = local.create_eks_subnets ? local.len_eks_subnets : 0

  cidr_block = element(concat(var.eks_subnets, [""]), count.index)
  vpc_id = local.vpc_id
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
        Name = try(
            var.eks_subnet_names[count.index],
            format("${var.name}-${var.eks_subnet_suffix}-%s", element(var.azs, count.index))
        )
    },
    var.tags,
    var.eks_subnet_tags,
    lookup(var.eks_subnet_tags_per_az, element(var.azs, count.index), {})
  )
}

resource "aws_route_table" "eks" {
  count = local.create_eks_subnets && local.max_subnet_length > 0 ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
        "Name" = var.single_nat_gateway ? "${var.name}-${var.eks_subnet_suffix}" : format(element(var.azs, count.index),
        )
    },
    var.tags,
    var.eks_route_table_tags,
  )
}

resource "aws_route_table_association" "eks" {
  count = local.create_eks_subnets ? local.len_eks_subnets : 0

  subnet_id = element(aws_subnet.eks[*].id, count.index)
  route_table_id = element(
    aws_route_table.eks[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )
}

resource "aws_route" "eks_nat_gateway" {
  count = local.create_eks_subnets && var.create_igw ? local.nat_gateway_count : 0

  route_table_id = aws_route_table.eks[count.index].ID
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = element(aws_nat_gateway.main[*].id, count.index)

  timeouts {
    create = "5m"
  }
}

######################################
# EKS Network ACLs
######################################

locals {
  create_eks_network_acl = local.create_eks_subnets && var.eks_dedicated_network_acl
}

resource "aws_network_acl" "eks" {
  count = local.create_eks_network_acl ? 1 : 0

  vpc_id = local.vpc_id
  subnet_ids = aws_subnet.eks[*].id

  tags = merge(
    { "Name" = "${var.name}-${var.eks_subnet_suffix}" },
    var.tags,
    var.eks_acl_tags,
  )
}

resource "aws_network_acl_rule" "eks_inbound" {
  count = local.create_eks_network_acl ? length(var.eks_inbound_acl_rules): 0

  network_acl_id = aws_network_acl.eks[0].id

  /* allow all inbound */
  egress = false
  rule_number = var.eks_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.eks_inbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.eks_inbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.eks_inbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.eks_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.eks_inbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.eks_inbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.eks_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "eks_outbound" {
  count = local.create_eks_network_acl ? length(var.eks_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.eks[0].id

  /* allow all inbound */
  egress = true
  rule_number = var.eks_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.eks_outbound_acl_rules[count.index]["rule_action"]
  from_port = lookup(var.eks_outbound_acl_rules[count.index], "from_port", null)
  to_port = lookup(var.eks_outbound_acl_rules[count.index], "to_port", null)
  icmp_code = lookup(var.eks_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type = lookup(var.eks_outbound_acl_rules[count.index], "icmp_type", null)
  protocol = var.eks_outbound_acl_rules[count.index]["protocol"]
  cidr_block = lookup(var.eks_outbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_security_group" "eks_sg" {
  name = "EKS-security-group"
  description = "Security group for EKS"
  vpc_id = local.vpc_id

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }
}

#######################################
# Internet Gateway
#######################################

resource "aws_internet_gateway" "main" {
  count = local.create_lb_subnets && var.create_igw ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.igw_tags,
  )
}

resource "aws_egress_only_internet_gateway" "main" {
  count = local.create_vpc && var.create_egress_only_igw && local.max_subnet_length > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.igw_tags,
  )
}

#########################################
# NAT Gateway
#########################################

locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
  nat_gateway_ips = var.reuse_nat_ips ? var.external_nat_ip_ids : try(aws_eip.nat[*].id, [])
}

resource "aws_eip" "nat" {
  count = local.create_vpc && var.enable_nat_gateway && !var.reuse_nat_ips ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
    {
        "Name" = format(
            "${var.name}-%s",
            element(var.azs, var.single_nat_gateway ? 0 : count.index),
        )
    },
    var.tags,
    var.nat_eip_tags,
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = local.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    aws_subnet.app[*].id,
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
        "Name" = format(
            "${var.name}-%s",
            element(var.azs, var.single_nat_gateway ? 0 : count.index),
        )
    },
    var.tags,
    var.nat_gatway_tags,
  )

  depends_on = [aws_internet_gateway.main]
}