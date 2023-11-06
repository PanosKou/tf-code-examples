data "template_file" "metricbeat_values" {
  template = file("${path.module}/files/metricbeat/values.yaml")
  vars = {
    cluster_name         = var.cluster_name
    logstash_host        = "${var.account_name}-elk-lb.${var.account_name}.aws.cloud.co.uk"
    logstash_port        = var.logstash_port
    prometheus_host_port = var.prometheus_host_port
    prometheus_period    = var.prometheus_period
    image_tag            = var.image_tag
    container_registry   = var.container_registry
  }
}

data "template_file" "filebeat_values" {
  template = file("${path.module}/files/filebeat/values.yaml")
  vars = {
    cluster_name       = var.cluster_name
    logstash_host      = "${var.account_name}-elk-lb.${var.account_name}.aws.cloud.co.uk"
    logstash_port      = var.logstash_port
    image_tag          = var.image_tag
    container_registry = var.container_registry
  }
}

data "template_file" "beats_policies_values" {
  template = file("${path.module}/files/beats-policies/values.yaml")
}

data "template_file" "filebeat_rbac_values" {
  template = file("${path.module}/files/filebeat-rbac/values.yaml")
}

//data "aws_lb" "logstash" {
//  name = "${var.account_name}-elk-nlb"
//}
