resource "kubernetes_namespace" "external_dns_namespace" {
  metadata {
    name   = var.namespace
    labels = merge(var.k8s_namespace_labels, { name = var.namespace })
  }
}

resource "aws_iam_role" "role" {
  name                 = "external-dns-${var.cluster_name}"
  assume_role_policy   = data.aws_iam_policy_document.trust_policy.json
  permissions_boundary = data.aws_iam_policy.custom-boundary.arn
}

resource "aws_iam_role_policy" "role_poicy" {
  name   = "external-dns-${var.cluster_name}"
  policy = data.aws_iam_policy_document.policy.json
  role   = aws_iam_role.role.id
}

resource "helm_release" "external_dns" {
  name        = "external-dns"
  chart       = "external-dns"
  version     = var.chart_version
  repository  = var.helm_repo_url
  values      = [data.template_file.values.rendered]
  namespace   = kubernetes_namespace.external_dns_namespace.id
  max_history = 5
}
