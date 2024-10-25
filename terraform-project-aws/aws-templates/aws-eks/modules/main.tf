terraform {
  required_providers {
    helm = {
        source = "hashicorp/helm"
    }
  }
}

resource "aws_eks_cluster" "projectekscluster" {
  name = var.cluster_name
  role_arn = var.project_clusterRole_arn
  version = var.cluster_version
  vpc_config {
    subnet_ids = var.subnet_ids
  }
    tags = {"alpha.eksctl.io/cluster-oidc-enabled" = "true"}

    # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
    # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
    depends_on = [
        aws_cloudwatch_log_group.projectekscloudwatch,
    ]
}

resource "aws_cloudwatch_log_group" "projectekscloudwatch" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
  name = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 7

  # ... potentially other configuration ...
}

resource "aws_eks_node_group" "project" {
  cluster_name = aws_eks_cluster.projectekscluster.name
  node_group_name = "ProjectNodeGroup"
  node_role_arn = var.project_nodegroup_role_arn //aws_iam_role.project_clusterRole_arn.arn
  subnet_ids = var.subnet_ids
  instance_types = var.cluster_instance_type
  scaling_config {
    desired_size = var.cluster_desired_size //2
    max_size = var.cluster_max_size //3
    min_size = var.cluster_min_size //2
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling. 
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces. 
  depends_on = [ 
    aws_eks_cluster.projectekscluster
   ]
}

resource "aws_eks_addon" "project_addoncoredns" {
  cluster_name = aws_eks_cluster.projectekscluster.name
  addon_name = "coredns"
  depends_on = [ aws_eks_cluster.projectekscluster ]
}

resource "aws_eks_addon" "project_addonvpccni" {
  cluster_name = aws_eks_cluster.projectekscluster.name
  addon_name = "vpc-cni"
  depends_on = [ aws_eks_cluster.projectekscluster ]
}

resource "aws_eks_addon" "project_EBSCSIDriver" {
  cluster_name = aws_eks_cluster.projectekscluster.name
  addon_name = "aws-ebs-csi-driver"
  depends_on = [ aws_eks_cluster.projectekscluster ]
}

resource "aws_eks_addon" "project_identity" {
  cluster_name = aws_eks_cluster.projectekscluster.name
  addon_name = "eks-pod-identity-agent"
  depends_on = [ aws_eks_cluster.projectekscluster ]
}

resource "aws_eks_addon" "project_Cloudwatch" {
  cluster_name = aws_eks_cluster.projectekscluster.name
  addon_name = "amazon-cloudwatch-observability"
  depends_on = [ aws_eks_cluster.projectekscluster ]
}

data "tls_certificate" "cluster_certficate" {
  depends_on = [ aws_eks_cluster.projectekscluster ]
  url = aws_eks_cluster.projectekscluster.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks_cluster_identity_provider" {
  depends_on = [ aws_eks_cluster.projectekscluster ]
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster_certficate.0.sha1_fingerprint]
  url = aws_eks_cluster.projectekscluster.identity.0.oidc.0.issuer
  tags = {"alpha.eksctl.io/cluster-name"="ProjecteksCluster","alpha.eksctl.io/eksctl-version" = "0.171.0"}
}

data "aws_eks_cluster" "cluster" {
  depends_on = [ aws_eks_cluster.projectekscluster ]
  name = aws_eks_cluster.projectekscluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  depends_on = [ aws_eks_cluster.projectekscluster ]
  name = aws_eks_cluster.projectekscluster.name
}

data "aws_iam_openid_connect_provider" "oidc_provider" {
  depends_on = [ aws_eks_cluster.projectekscluster ]
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

module "api_gateway" {
  count = var.create_apigw ? 1:0
  source = "./modules/apigw"
  subnet_ids = var.subnet_ids
  security_group_ids = var.security_group_ids
}

resource "kubenetes_service_account" "deploy_robot" {
  metadata {
    name = "deploy-robot"
    namespace = "default"
    annotations = {
        "kubectl.kubernetes.io/last-applied-configuration" = jsonencode({
            apiVersion = "v1",
            automountServiceAccountToken = false,
            kind = "ServiceAccount",
            metadata = {
                annotations = {},
                name = "deploy-robot",
                namespace = "default"
            }
        })
    }
  }
  automount_service_account_token = false
}