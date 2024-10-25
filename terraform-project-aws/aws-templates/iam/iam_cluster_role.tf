output "project_clusterRole_arn" {
  value = aws_iam_role.project_clusterRole.arn
}

resource "aws_iam_role" "project_clusterRole" {
  name = "project_eks-cluster-role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "project_clusterRole" {
  count = var.eks_role_createdManually ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazondEKSClusterPolicy"
  role = aws_iam_role.project_clusterRole.name
}