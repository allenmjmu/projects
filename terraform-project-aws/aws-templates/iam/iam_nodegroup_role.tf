output "project_nodegroup_role_arn" {
  value = aws_iam_role.project_nodegroup_role.arn 
}

resource "aws_iam_role" "project_nodegroup_role" {
  name = "project_eks-node-group"
  description = "RITM14424021"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement1",
            "Effect": "Allow",
            "Principal": {
                "Service": ["ec2.amazonaws.com","eks.amazonaws.com"]
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "project-AmazonEKSWorkerNodePolicy" {
  count = var.eks_role_createdManually ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.project_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "project-AmazonEKS_CNI_Policy" {
  count = var.eks_role_createdManually ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.project_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "project-AmazonEC2ContainerRegistryReadOnly" {
  count = var.eks_role_createdManually ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role = aws_iam_role.project_nodegroup_role.name
}