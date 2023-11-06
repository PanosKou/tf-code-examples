variable "feature_metricbeat" {
  type        = number
  default     = 1
  description = "Flag to deploy metricbeat."
}

variable "feature_filebeat" {
  type        = number
  default     = 1
  description = "Flag to deploy filebeat."
}

variable "k8s_namespace" {
  type        = string
  default     = "beats"
  description = "k8s Namespace to create to deploy beats to."
}

variable "k8s_namespace_labels" {
  type        = map
  description = "K8S Namespace labels"
  default     = {}
}

variable "logstash_port" {
  type        = string
  default     = "5044"
  description = "Port of logstash server / logstash LB."
}

variable "helm_version" {
  type        = string
  default     = "7.10"
  description = "Beats version."
}

variable "helm_repo" {
  type        = string
  default     = "https://artifactory.aws.cloud.co.uk/artifactory/example-helm"
  description = "Helm repository for beats."
}

variable "container_registry" {
  type        = string
  default     = "dev-docker-rel-local.artifactory.aws.cloud.co.uk"
  description = "Artifactory repository for storing docker containers used by core components on the cluster"
}

variable "image_tag" {
  type        = string
  default     = "7.10.0"
  description = "Beats Image Tag."
}

variable "cluster_name" {
  type        = string
  default     = "unknown"
  description = "Cluster name as added field to help differentiate clusters in the same Elasticsearch index."
}

variable "prometheus_host_port" {
  type        = string
  default     = "kube-prometheus-stack-prometheus.monitoring.svc.cluster.local:9090"
  description = "K8s Cluster name and port for prometheus to scrape for metrics."
}

variable "prometheus_period" {
  type        = string
  default     = "180s"
  description = "Prometheus scrape interval to use."
}

variable "account_name" {
  type        = string
  description = "Account Name."
}
