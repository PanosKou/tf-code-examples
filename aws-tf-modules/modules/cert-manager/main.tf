resource "kubernetes_namespace" "cert_manager_namespace" {
  metadata {
    name   = var.namespace
    labels = merge(var.k8s_namespace_labels, { name = var.namespace })
  }
}

resource "helm_release" "cert_manager_crds" {
  depends_on  = [kubernetes_namespace.cert_manager_namespace]
  name        = "cert-manager-crds"
  chart       = "${path.module}/charts/cert-manager-crds"
  namespace   = var.namespace
  max_history = 5
}

resource "helm_release" "cert_manager" {
  depends_on  = [helm_release.cert_manager_crds]
  name        = "cert-manager"
  chart       = "cert-manager"
  repository  = var.helm_repo_url
  values      = [data.template_file.cert_manager_values.rendered]
  namespace   = var.namespace
  version     = var.chart_version
  max_history = 5
}

resource "null_resource" "cert_manager_wait" {
  triggers = {
    hash = sha256(data.template_file.cert_manager_values.rendered)
  }
  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "helm_release" "self_signed_ssuer" {
  depends_on  = [null_resource.cert_manager_wait, helm_release.cert_manager]
  name        = "self-signed-issuer"
  chart       = "${path.module}/charts/self-signed-issuer"
  namespace   = var.namespace
  max_history = 5
}

resource "helm_release" "vault_issuer" {
  depends_on  = [null_resource.cert_manager_wait, helm_release.cert_manager]
  name        = "vault-issuer"
  chart       = "${path.module}/charts/vault-issuer"
  values      = [data.template_file.vault_issuer_values.rendered]
  namespace   = var.namespace
  max_history = 5
}
