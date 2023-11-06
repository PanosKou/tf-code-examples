data "template_file" "values" {
  template = file("${path.module}/files/values.yaml")
  vars = {
    cluster_name        = var.cluster_name
    private_hosted_zone = var.private_hosted_zone
    container_registry  = var.container_registry
    ingress_class       = var.ingress_class
  }
}
