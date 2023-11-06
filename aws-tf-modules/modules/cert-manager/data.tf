data "template_file" "cert_manager_values" {
  template = file("${path.module}/files/cert-manager-values.yaml")
  vars = {
    service_monitor_enabled = var.service_monitor_enabled
    psp_enabled             = var.psp_enabled
    container_registry      = var.container_registry
  }
}

data "template_file" "vault_issuer_values" {
  template = file("${path.module}/files/vault-issuer-values.yaml")
  vars = {
    caBundle                = base64encode(var.nbs_management_networking_ca_pem)
    vault_path              = var.vault_path
    vault_server            = var.vault_addr
    vault_role              = var.vault_role
    vault_mount_path        = var.vault_mount_path
    certmgr_sa_secret       = data.kubernetes_service_account.cert_manager.default_secret_name
    vault_backend_namespace = var.vault_backend_namespace
  }
}

data "kubernetes_service_account" "cert_manager" {
  metadata {
    name      = "cert-manager"
    namespace = var.namespace
  }
  depends_on = [null_resource.cert_manager_wait, helm_release.cert_manager]
}
