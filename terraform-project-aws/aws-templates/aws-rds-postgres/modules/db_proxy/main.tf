locals {
  role_arn = var.create && var.create_iam_role ? aws_iam_role.main[0].arn : var.role_arn
  role_name = coalesce(var.iam_role_name, var.name)
  policy_name = coalesce(var.iam_policy_name, var.name)
}

data "aws_region" "current" {}
data "aws_partition" "current" {}

###############################################
# RDS Proxy
###############################################

resource "aws_db_proxy" "main" {
  count = var.create ? 1 : 0

  dynamic "auth" {
    for_each = var.auth

    content {
      client_password_auth_type = try(auth.value.client_password_auth_type, null) 
      username = try(auth.value.username, null)
    }
  }

  engine_family = var.engine_family 
  idle_client_timeout = var.idle_client_timeout
  name = var.name 
  role_arn = local.role_arn 
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids = var.vpc_subnet_ids 

  tags = merge(var.tags, var.proxy_tags)

  depends_on = [aws_cloudwatch_log_group.main]
}

resource "aws_db_proxy_default_target_group" "main" {
  count = var.create ? 1 : 0
  db_proxy_name = aws_db_proxy.main[0].name
}

resource "aws_db_proxy_endpoint" "main" {
  for_each = { for k, v in var.endpoints : k => v if var.create }

  db_proxy_name = aws_db_proxy.main[0].name
  db_proxy_endpoint_name = each.value.name
  vpc_subnet_ids = each.value.vpc_subnet_ids

  tags = lookup(each.value, "tags", var.tags)
}

###########################################
# IAM Role
###########################################

data "aws_iam_policy_document" "assume_role" {
  count = var.create && var.create_iam_role ? 1 : 0

  statement {
    sid = "RDSAssume"
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["rds.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

resource "aws_iam_role" "main" {
  count = var.create && var.create_iam_role ? 1 : 0

  name = var.use_role_name_prefix ? null : local.role_name
  name_prefix = var.use_role_name_prefix ? "${local.role_name}-" : null
  description = var.iam_role_description
  path = var.iam_role_path

  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration = var.iam_role_max_session_duration
  permissions_boundary = var.iam_role_permission_boundary

  tags = merge(var.tags, var.iam_role_tags)
}

data "aws_iam_policy_document" "main" {
    count = var.create && var.create_iam_role && var.create_iam_policy ? 1 : 0

    statement {
      sid = "DecryptSecrets"
      effect = "Allow"
      actions = ["kms:Decrypt"]
      resources = coalescelist(
        var.kms_key_arns,
        ["arn:${data.aws_partition.current.partition}:kms:*:*:key/*"]
      )
      
      condition {
        test = "StringEquals"
        variable = "kms:ViaService"
        values = [
            "secretsmanager.${data.aws_region.current.name}.${data.aws_partition.current.dns_suffix}"
        ]
      }
    }

    statement {
      sid = "ListSecrets"
      effect = "Allow"
      actions = [
        "secretsmanager:GetRandomPassword",
        "secretsmanager:ListSecrets",
      ]
      resources = ["*"]
    }

    statement {
      sid = "GetSecrets"
      effect = "Allow"
      actions = [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds",
      ]

      resources = distinct([for auth in var.auth : auth.secret_arn])
    }
}

resource "aws_iam_role_policy" "main" {
    count = var.create && var.create_iam_role && var.create_iam_policy ? 1 : 0

    name = var.use_policy_name_prefix ? null : local.policy_name
    name_prefix = var.use_policy_name_prefix ? "${local.policy_name}-" : null
    policy = data.aws_iam_policy_document.main[0].json
    role = aws_iam_role.main[0].id
}