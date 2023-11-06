resource "kubernetes_namespace" "beats_namespace" {
  metadata {
    name   = var.k8s_namespace
    labels = merge(var.k8s_namespace_labels, { name = var.k8s_namespace })
  }
}

resource "helm_release" "beats_policies" {
  name        = "beats-policies"
  chart       = "${path.module}/charts/beats-policies"
  namespace   = var.k8s_namespace
  values      = [data.template_file.beats_policies_values.rendered]
  max_history = 5
}

# Required so we can add PSP usage for filebeat. See readme.
resource "helm_release" "filebeat_rbac" {
  count = var.feature_filebeat

  name        = "filebeat-rbac"
  chart       = "${path.module}/charts/filebeat-rbac"
  namespace   = var.k8s_namespace
  values      = [data.template_file.filebeat_rbac_values.rendered]
  max_history = 5
}

resource "helm_release" "metricbeat" {
  count = var.feature_metricbeat

  name       = "metricbeat"
  repository = var.helm_repo
  chart      = "metricbeat"
  values     = [data.template_file.metricbeat_values.rendered]
  namespace  = var.k8s_namespace
  version    = var.helm_version

  depends_on = [kubernetes_namespace.beats_namespace, helm_release.beats_policies]
}

resource "helm_release" "filebeat" {
  count = var.feature_filebeat

  name       = "filebeat"
  repository = var.helm_repo
  chart      = "filebeat"
  values     = [data.template_file.filebeat_values.rendered]
  namespace  = var.k8s_namespace
  version    = var.helm_version

  depends_on = [kubernetes_namespace.beats_namespace, helm_release.filebeat_rbac, helm_release.beats_policies]
}
