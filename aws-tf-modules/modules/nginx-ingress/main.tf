resource "kubernetes_namespace" "ingress_nginx_namespace" {
  metadata {
    name   = var.nginx_ingress_namespace
    labels = merge(var.k8s_namespace_labels, { name = var.nginx_ingress_namespace })
  }
}

resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = var.helm_repo_url
  chart      = "ingress-nginx"
  values     = [data.template_file.values.rendered]
  namespace  = var.nginx_ingress_namespace
  version    = var.ingress_chart_version
  depends_on = [kubernetes_namespace.ingress_nginx_namespace]
}
