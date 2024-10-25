
# Role
data "aws_iam_policy_document" "kubernetes_alb_controller_assume" {
  count = var.enabled ? 1 : 0

  statement {
    actions = ["sts.AssumeRoleWithWebIdentity"]

    principals {
        type = "Federated"
        identifiers = [var.cluster_identity_oidc_issuer.arn]
    }

    condition {
        test = "StringEquals"
        variable = "${replace(var.cluster_identity_oidc_issuer.url, "https://", "")}:sub"

        values = ["system:serviceaccount:${var.namespace}:${var.service_account_name}",
        ]
    }

    condition {
        test = "StringEquals"
        variable = "${replace(var.cluster_identity_oidc_issuer.url, "https://", "")}:sub"

        values = [
            "sts.amazonaws.com"
        ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "kubernetes_alb_controller" {
  count = var.enabled ? 1 : 0
  name = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.kubernetes_alb_controller_assume[0].json
}

resource "aws_iam_role_policy_attachment" "kubernetes_alb_controller" {
  count = var.enabled ? 1 : 0
  role = aws_iam_role.kubernetes_alb_controller[0].name
  policy_arn = var.kubernetes_alb_controller_arn
}