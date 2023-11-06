data "template_file" "metrics_server_values" {
  template = file("${path.module}/files/values.yaml")
  vars = {
    container_registry = var.container_registry
  }
}
