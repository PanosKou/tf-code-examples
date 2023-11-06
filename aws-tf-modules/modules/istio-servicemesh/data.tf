data "template_file" "kiali_values" {
  template = file("${path.module}/files/kiali_values.yaml")
  vars = {
    cluster_name        = var.cluster_name
    private_hosted_zone = var.private_hosted_zone
    container_registry  = var.container_registry
    ingress_class       = var.ingress_class
    kiali_auth_method   = var.kiali_auth_method
    kiali_version       = var.kiali_version
    kiali_namespace     = var.namespace
  }
}
