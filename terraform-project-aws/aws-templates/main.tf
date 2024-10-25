provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host = module.eks.eks_endpoint
    cluster_ca_certificate = base64decode(module.eks.certifcate_authority)
    token = module.eks.clustertoken
  }
}

provider "kubernetes" {
    host = module.eks.eks_endpoint
    cluster_ca_certificate = base64decode(module.eks.certifcate_authority)
    token = module.eks.clustertoken
}

module "vpc" {
  source = "./aws-vpc"
}

module "iam" {
  source = "./iam"
  eks_role_createdManually = var.eks_role_createdManually
}

module "s3" {
  source = "./aws-s3"
  environment = var.environment
}

module "sqs" {
  count = var.create_sqs ? 1 : 0
  source = "./aws-sqs"
  environment = var.environment
}

module "rds" {
  count = var.create_rds ? 1 : 0
  source = "./aws-rds-postgres"
  subnet_ids = module.vpc.elasticache_subnets
  password = var.rds_password
  depends_on = [ module.vpc,module.iam,module.s3,module.sqs ]
}

module "redis" {
  count = var.create_redis ? 1 : 0
  source = "./aws-redis"
  subnet_ids = module.vpc.elasticache_subnets
  security_group_ids = [module.vpc.eks_security_group_id]
  depends_on = [ module.vpc,module.iam,module.s3,module.sqs ]
}

module "eks" {
  source = "./aws-eks"
  depends_on = [ module.vpc,module.iam,module.s3,module.sqs ]
#   cluster_name = var.cluster_name
#   subnet_ids = module.vpc.eks_subnet_ids
#   security_group_ids = module.vpc.eks_subnet_ids
#   region = var.aws_region
#   cluster_instance_type = var.cluster_instance_type
#   cluster_desired_size = var.cluster_desired_size
#   cluster_max_size = var.cluster_max_size
#   cluster_min_size = var.cluster_min_size
#   cluster_version = var.cluster_version
#   create_apigw = var.create_apigw
#   eks_role_createdManually = var.eks_role_createdManually
#   project_clusterRole_arn = module.iam.project_clusterRole_arn
#   project_nodegroup_role_arn = module.iam.project_nodegroup_role_arn

  providers = {
    helm = helm
  }
}

module "alb-controller-iam" {
  depends_on = [ module.eks ]
  source = "./alb-controller-iam"
  enabled = var.alb-controller-iam_enabled
  cluster_identity_oidc_issuer = module.eks.data_aws_iam_openid_connect_provider //data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  cluster_name = var.cluster_name
#   kubernetes_alb_controller_policy_arn = module.iam.kubernetes_alb_controller_policy_arn
  namespace = var.namespace
  service_account_name = var.service_account_name
  kubernetes_alb_controller_arn = modeule.iam.kubernetes_alb_controller_arn
}

module "alb_controller" {
  depends_on = [ module.eks,module.alb-controller-iam ]
  source = "./alb-controller"
  cluster_name = var.cluster_name
  cluster_identity_oidc_issuer = module.eks.data_aws_eks_cluster.identity.0.oidc.0.issuer //data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
  cluster_identity_oidc_issuer_arn = module.eks.data_aws_iam_openid_connect_provider.arn //data.aws_iam_openid_connect_provider.oidc_provider.arn 
  aws_region = var.aws_region
  kubernetes_alb_controller_policy_arn = module.iam.kubernetes_alb_controller_policy_arn
  namespace = var.namespace
  service_account_name = var.service_account_name
  aws_iam_role-kubernetes_alb_controller = module.alb-controller-iam.aws_iam_role-kubernetes_alb_controller
}