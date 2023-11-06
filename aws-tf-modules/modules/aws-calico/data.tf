data "template_file" "values" {
  template = file("${path.module}/files/values.yaml")
  vars = {
    psp_enabled        = var.psp_enabled
    container_registry = var.container_registry
  }
}

data "template_file" "global_network_policies_values" {
  template = file("${path.module}/files/global-network-policies/values.yaml")
}
