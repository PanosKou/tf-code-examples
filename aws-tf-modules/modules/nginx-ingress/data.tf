data "template_file" "values" {
  template = file("${path.module}/files/values.yaml")
  vars = {
    service_monitor_enabled = var.service_monitor_enabled
    psp_enabled             = var.psp_enabled
    container_registry      = var.container_registry
    ingress_class           = var.ingress_class
  }
}