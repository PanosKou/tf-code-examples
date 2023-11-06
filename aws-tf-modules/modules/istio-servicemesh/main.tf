
terraform {
  required_version = ">= 0.13"
}

resource "kubernetes_namespace" "istio_mesh_namespace" {
  metadata {
    name   = var.namespace
    labels = merge(var.k8s_namespace_labels, { name = var.namespace })
  }
}

resource "helm_release" "istio_operator" {
  namespace   = var.namespace
  name        = "istio-operator"
  chart       = "${path.module}/charts/istio-servicemesh-operator"
  version     = var.chart_version
  max_history = 5
  depends_on  = [kubernetes_namespace.istio_mesh_namespace]

}

locals {
  profile_values = {
    profile_name : var.istio_operator_profile
  }
}

resource "helm_release" "istio_operator_profile" {
  namespace   = var.namespace
  count       = length(var.istio_operator_profile) > 0 ? 1 : 0
  name        = "istio-operator-profile"
  chart       = "${path.module}/charts/istio-servicemesh-profile"
  version     = var.chart_version
  values      = [yamlencode(local.profile_values)]
  max_history = 5
  depends_on  = [helm_release.istio_operator, kubernetes_namespace.istio_mesh_namespace]
}

resource "helm_release" "kiali_server" {
  namespace   = var.namespace
  count       = var.feature_istio_kiali
  name        = "kiali-server"
  chart       = "${path.module}/charts/istio-servicemesh-kiali"
  version     = var.kiali_version
  values      = [data.template_file.kiali_values.rendered]
  max_history = 5
  depends_on  = [helm_release.istio_operator, kubernetes_namespace.istio_mesh_namespace]
}
