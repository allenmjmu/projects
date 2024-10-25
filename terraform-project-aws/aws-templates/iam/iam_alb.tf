output "kubernetes_alb_controller_policy_arn" {
  value = aws_iam_policy.kubernetes_alb_controller.arn 
}

resource "aws_iam_policy" "kubernetes_alb_controller" {
  name = "${var.cluster_name}-alb-controller"
  path = "/"

  policy = file("${path.module}/alb_controller_policy.json")
}