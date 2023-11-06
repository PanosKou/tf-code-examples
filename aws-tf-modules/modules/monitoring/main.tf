resource "kubernetes_namespace" "monitoring_namespace" {
  metadata {
    name   = var.monitoring_namespace
    labels = merge(var.k8s_namespace_labels, { name = var.monitoring_namespace })
  }
}

resource "helm_release" "monitoring" {
  name       = "kube-prometheus-stack"
  repository = var.helm_repo_url
  chart      = "kube-prometheus-stack"
  values     = [data.template_file.values.rendered]
  namespace  = var.monitoring_namespace
  version    = var.prometheus_chart_version
  depends_on = [kubernetes_namespace.monitoring_namespace]
}
