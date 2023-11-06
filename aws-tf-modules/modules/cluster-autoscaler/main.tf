resource "aws_iam_role" "role" {
  name                 = "cluster-autoscaler-${var.cluster_name}"
  assume_role_policy   = data.aws_iam_policy_document.trust_policy.json
  permissions_boundary = data.aws_iam_policy.custom-boundary.arn
}

resource "aws_iam_role_policy" "role_poicy" {
  name   = "cluster-autoscaler-${var.cluster_name}"
  policy = data.aws_iam_policy_document.policy.json
  role   = aws_iam_role.role.id
}

resource "helm_release" "cluster_autoscaler" {
  name        = "cluster-autoscaler"
  chart       = "cluster-autoscaler"
  version     = var.chart_version
  repository  = var.helm_repo_url
  values      = [data.template_file.values.rendered]
  namespace   = "kube-system"
  max_history = 5
  depends_on  = [kubernetes_network_policy.allow_egress_autoscaler]
}
