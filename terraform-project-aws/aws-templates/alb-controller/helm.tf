resource "helm_release" "alb_controller" {
  count = var.enabled ? 1 : 0
  name = var.helm_chart_name
  chart = var.helm_chart_release_name
  repository = var.helm_chart_repo
  version = var.helm_chart_version
  namespace = var.namespace

    set {
        name = "clusterName"
        value = var.cluster_name
    }

    set {
        name = "awsRegions"
        value = var.aws_region
    }

    set {
        name = "rbac.create"
        value = "true"
    }

    set {
        name = "serviceAccount.create"
        value = "true"
    }

    set {
        name = "serviceAccount.name"
        value = "true"
    }

    set {
        name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
        value = var.aws_iam_role-kubernetes_alb_controller[0].arn //aws_iam_role.kubernetes_alb_controller[0].arn
    }

    set {
        name = "enableServiceMutatorWebhook"
        value = "false"
    }

    values = [
        yamlencode(var.settings)
    ]
}