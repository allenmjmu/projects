output "eks_endpoint" {
  value = aws_eks_cluster.projectekscluster.endpoint
}

output "certificate_authority" {
  value = aws_eks_cluster.projectekscluster.certficate_authority[0].data
}

output "clustertoken" {
  value = data.aws_eks_cluster_auth.cluster.token
}

output "host" {
  value = data.aws_eks_cluster.cluster.endpoint
}

output "endpoint" {
  value = aws_eks_cluster.projectekscluster.endpoint
}

output "kubeconfig-certifiate-authority-data" {
  value = aws_eks_cluster.projectekscluster.certificate_authority[0].data
}

output "data_aws_eks_cluster" {
  value = data.aws_eks_cluster.cluster
}

output "data_aws_iam_openid_connect_provider" {
  value = data.aws_iam_openid_connect_provider.oidc_provider
}