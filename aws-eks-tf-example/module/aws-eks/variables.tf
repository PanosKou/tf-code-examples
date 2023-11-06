variable "account_name" {
  type        = string
  description = "NBS Account Name"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster to be created"
}

variable "central_vpn_cidr_blocks" {
  type        = list(string)
  default     = ["10.160.68.0/24", "10.160.69.0/24", "10.160.70.0/24"]
  description = "VPN cidr blocks to access eks"
}

variable "container_registry" {
  type        = string
  default     = "example-docker-rel-local.artifactory.aws.cloud.co.uk"
  description = "Artifactory repository for storing docker containers used by core components on the cluster"
}

variable "helm_repo_url" {
  type        = string
  description = "Helm Repo url"
  default     = "https://artifactory.aws.cloud.co.uk/artifactory/example-helm"
}

variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "SSH Pubkey to for ssh access to worker nodes.. if not specified key named {var.cluster_name}-eks-workers will be created and its details are stored in secrets manager"
}

variable "k8s_namespace_labels" {
  type = map
  default = {
    component  = "core-service"
    managed-by = "terraform"
    part-of    = "aws-eks"
  }
  description = "K8S Namespace Labels for core services namespace"
}

variable "feature_eks" {
  default     = 1
  description = "Feature flag to enable eks cluster creation. You may choose to disable this when targeting an existing cluster"
}

variable "feature_eks_custom_vpc_cni" {
  default     = 1
  description = "Feature flag to enable custom VPC CNI configuration. This feature enables secondary subnets and other AWS CNI specific customisation."
}

variable "feature_aws_calico" {
  default     = 1
  description = "Feature flag to enable calico support. This feature enables network policies"
}

variable "feature_eks_workers" {
  default     = 1
  description = "Feature flag to enable worker creation using worker groups"
}

variable "feature_vault_auth" {
  default     = 1
  description = "Feature flag to enable the vault-integration module"
}

variable "feature_storage_class" {
  default     = 1
  description = "Feature flag to enable the encrypted storage class module"
}

variable "feature_ingress_nginx" {
  default     = 1
  description = "Feature flag to enable the internal nginx ingress controller module"
}

variable "feature_monitoring" {
  default     = 1
  description = "Feature flag to enable prometheus monitoring module"
}

variable "feature_cert_manager" {
  default     = 1
  description = "Feature flag to enable cert manager module"
}

variable "feature_external_dns" {
  default     = 1
  description = "Feature flag to enable external DNS module"
}

variable "feature_istio_servicemesh" {
  default     = 1
  description = "Feature flag to enable istio service mesh"
}

variable "istio_operator_profile" {
  default     = "default"
  description = "Name of the istio-operator profile to install, set to null to skip profile installation"
}

variable "feature_pod_security_policies" {
  default     = 1
  description = "Feature flag to enable PSPs in the cluster"
}

variable "feature_metrics_server" {
  default     = 1
  description = "Feature flag to enable metrics server"
}

variable "feature_cluster_autoscaler" {
  default     = 1
  description = "Feature flag to enable cluster autoscaler in the cluster"
}

variable "feature_beats" {
  default     = 1
  description = "Feature flag to enable beats"
}

variable "feature_metricbeat" {
  type        = number
  default     = 1
  description = "Flag to deploy metricbeat. To turn one off/on."
}

variable "feature_filebeat" {
  type        = number
  default     = 1
  description = "Flag to deploy filebeat. To turn one off/on."
}

variable "worker_groups" {
  type        = any
  description = "List of worker groups with each its own ASG and config"
}

variable "tf_role" {
  type        = string
  description = "Role used by terraform for null_resources"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets ids for worker nodes"
  default     = []
}

variable "intra_subnet_ids" {
  type        = list(string)
  description = "Intra Subnet ids for pods running on worker nodes"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the cluster would be created"
  default     = ""
}

variable "cluster_encryption_key_arn" {
  type        = string
  description = "KMS Key ARN to be used for encryption within the cluster. Used for both EBS encryption and ETCD encryption of secrets."
}

variable "vault_cidrs" {
  type        = list
  description = "CIDR ranges for vault subnets. Defaults to teams vault CIDRs"
  default     = ["10.160.204.0/24", "10.160.205.0/24", "10.160.206.0/24"]
}

variable "vault_addr" {
  type        = string
  description = "Vault instance address. Defaults to CCOE instance of vault."
  default     = "https://vault.aws.cloud.co.uk/"
}

variable "worker_tags" {
  type        = map(string)
  default     = {}
  description = "Tags for worker nodes created in the module"
}

variable "enable_default_rbac_roles" {
  type        = number
  description = "Enable default rbac roles"
  default     = 1
  validation {
    condition     = var.enable_default_rbac_roles == 0 || var.enable_default_rbac_roles == 1
    error_message = "The enable_default_rbac_roles value must '0' or '1'."
  }
}

variable "custom_rbac_mappings" {
  description = "Additional IAM roles to be add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "logstash_port" {
  type        = string
  default     = "5044"
  description = "Port of logstash server / logstash LB."
}

variable "beats_prometheus_period" {
  type        = string
  default     = "320s"
  description = "Prometheus scrape interval to use."
}
