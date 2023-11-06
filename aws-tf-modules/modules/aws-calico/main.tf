resource "helm_release" "aws_calico" {
  name        = "aws-calico"
  chart       = "aws-calico"
  version     = var.chart_version
  repository  = var.helm_repo_url
  values      = [data.template_file.values.rendered]
  namespace   = "kube-system"
  max_history = 5
}

resource "helm_release" "global_network_policies" {
  depends_on  = [helm_release.aws_calico]
  name        = "global-network-policies"
  chart       = "${path.module}/charts/global-network-policies"
  values      = [data.template_file.global_network_policies_values.rendered]
  namespace   = "kube-system"
  max_history = 5
}
