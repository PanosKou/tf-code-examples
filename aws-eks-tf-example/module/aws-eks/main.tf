locals {
  subnet_ids              = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnet_ids.private_subnets.ids
  tf_role                 = var.tf_role != "" ? var.tf_role : format("%s-role-app-creator", var.account_name)
  vpc_id                  = var.vpc_id != "" ? var.vpc_id : data.aws_vpc.vpc.id
  service_monitor_enabled = var.feature_monitoring > 0
  psp_enabled             = var.feature_pod_security_policies > 0
  vault_role              = "eks-kube-auth-${var.cluster_name}-role"
  vault_auth_path         = "auth/eks-kube-auth-${var.cluster_name}"
  internal_ingress_class  = "internal-ingress"
  private_hosted_zone     = "${var.account_name}.aws.nbscloud.co.uk"
}

module "eks" {
  count = var.feature_eks

  source                     = "git@github.com:example-test-repo/aws-components.git//modules/eks?ref=eks-18.0.3"
  account_name               = var.account_name
  central_vpn_cidr_blocks    = var.central_vpn_cidr_blocks
  cluster_name               = var.cluster_name
  subnet_ids                 = local.subnet_ids
  vpc_id                     = local.vpc_id
  vpc_cidrs                  = list(data.aws_vpc.vpc.cidr_block)
  tf_role                    = local.tf_role
  cluster_encryption_key_arn = var.cluster_encryption_key_arn
}

module "eks-aws-auth" {
  source                    = "git@github.com:example-test-repo/aws-components.git//modules/eks-aws-auth?ref=eks-aws-auth-0.0.2"
  account_name              = var.account_name
  cluster_name              = var.cluster_name
  custom_rbac_mappings      = var.custom_rbac_mappings
  enable_default_rbac_roles = var.enable_default_rbac_roles
  k8s_namespace_labels      = var.k8s_namespace_labels

  depends_on = [module.eks]
}

module "psp" {
  count = var.feature_pod_security_policies

  source          = "git@github.com:example-test-repo/aws-components.git//modules/psp?ref=psp-0.0.2"
  cluster_name    = var.cluster_name
  cluster_version = module.eks[0].cluster_version
  tf_role         = local.tf_role

  depends_on = [module.eks-aws-auth]
}

module "eks-custom-vpc-cni" {
  count = var.feature_eks_custom_vpc_cni

  source                    = "git@github.com:example-test-repo/aws-components.git//modules/eks-custom-vpc-cni?ref=eks-custom-vpc-cni-0.0.3"
  account_name              = var.account_name
  cluster_name              = var.cluster_name
  vpc_id                    = local.vpc_id
  worker_security_group_id  = module.eks[0].worker_security_group_id
  cluster_security_group_id = module.eks[0].cluster_security_group_id
  tf_role                   = local.tf_role

  depends_on = [module.psp]
}

module "aws-calico" {
  count = var.feature_aws_calico

  source             = "git@github.com:example-test-repo/aws-components.git//modules/aws-calico?ref=aws-calico-0.0.6"
  container_registry = var.container_registry
  helm_repo_url      = var.helm_repo_url
  psp_enabled        = local.psp_enabled

  depends_on = [module.eks-custom-vpc-cni]
}

module "eks-workers" {
  count = var.feature_eks_workers

  source = "git@github.com:example-test-repo/aws-components.git//modules/eks-workers?ref=eks-workers-0.0.3"

  account_name                     = var.account_name
  central_vpn_cidr_blocks          = var.central_vpn_cidr_blocks
  cluster_name                     = var.cluster_name
  cluster_ca_b64                   = module.eks[0].cluster_ca_b64
  cluster_endpoint                 = module.eks[0].cluster_endpoint
  worker_security_group_id         = module.eks[0].worker_security_group_id
  cluster_security_group_id        = module.eks[0].cluster_security_group_id
  cluster_version                  = module.eks[0].cluster_version
  nationwide_root_ca2_pem          = data.local_file.nationwide_root_ca2_pem.content
  nbs_management_networking_ca_pem = data.local_file.nbs_management_networking_ca_pem.content
  subnet_ids                       = local.subnet_ids
  ssh_public_key                   = var.ssh_public_key
  tags                             = var.worker_tags
  tf_role                          = local.tf_role
  vpc_id                           = local.vpc_id
  worker_groups                    = var.worker_groups


  depends_on = [module.eks-custom-vpc-cni, module.eks-aws-auth]
}

module "storage-class" {
  count = var.feature_storage_class

  source                     = "git@github.com:example-test-repo/aws-components.git//modules/storage-class?ref=storage-class-0.0.6"
  cluster_encryption_key_arn = var.cluster_encryption_key_arn
  cluster_name               = var.cluster_name
  tf_role                    = local.tf_role

  depends_on = [module.eks-workers]
}

module "ingress-nginx" {
  count = var.feature_ingress_nginx

  source                  = "git@github.com:example-test-repo/aws-components.git//modules/nginx-ingress?ref=nginx-ingress-0.0.10"
  service_monitor_enabled = local.service_monitor_enabled
  psp_enabled             = local.psp_enabled
  helm_repo_url           = var.helm_repo_url
  container_registry      = var.container_registry
  ingress_class           = local.internal_ingress_class
  k8s_namespace_labels    = var.k8s_namespace_labels

  depends_on = [module.monitoring]
}

module "monitoring" {
  count = var.feature_monitoring

  source               = "git@github.com:example-test-repo/aws-components.git//modules/monitoring?ref=monitoring-0.0.10"
  cluster_name         = var.cluster_name
  private_hosted_zone  = local.private_hosted_zone
  ingress_class        = local.internal_ingress_class
  container_registry   = var.container_registry
  helm_repo_url        = var.helm_repo_url
  psp_enabled          = local.psp_enabled
  k8s_namespace_labels = var.k8s_namespace_labels

  depends_on = [module.eks-workers]
}

module "cert-manager" {
  count = var.feature_cert_manager

  source                           = "git@github.com:example-test-repo/aws-components.git//modules/cert-manager?ref=cert-manager-0.0.9"
  vault_addr                       = var.vault_addr
  vault_path                       = "pki/sign/${local.private_hosted_zone}-role"
  vault_role                       = local.vault_role
  vault_backend_namespace          = var.account_name
  vault_mount_path                 = "/v1/${var.account_name}/${local.vault_auth_path}/"
  service_monitor_enabled          = local.service_monitor_enabled
  nbs_management_networking_ca_pem = data.local_file.nbs_management_networking_ca_pem.content
  psp_enabled                      = local.psp_enabled
  container_registry               = var.container_registry
  helm_repo_url                    = var.helm_repo_url
  k8s_namespace_labels             = var.k8s_namespace_labels

  depends_on = [module.monitoring]
}

module "vault-integration" {
  count = var.feature_vault_auth

  source = "git@github.com:example-test-repo/aws-components.git//modules/vault-integration?ref=vault-0.0.9"
  annotations = {
    "vault.hashicorp.com/namespace"       = var.account_name
    "vault.hashicorp.com/auth-path"       = local.vault_auth_path
    "vault.hashicorp.com/role"            = local.vault_role
    "vault.hashicorp.com/tls-skip-verify" = "true"
  }
  vault_addr                = var.vault_addr
  vault_auth_path           = local.vault_auth_path
  vault_cidrs               = var.vault_cidrs
  cluster_security_group_id = module.eks[0].cluster_security_group_id
  cluster_name              = var.cluster_name
  container_registry        = var.container_registry
  helm_repo_url             = var.helm_repo_url
  psp_enabled               = local.psp_enabled
  k8s_namespace_labels      = var.k8s_namespace_labels

  depends_on = [module.eks-workers]
}

module "external-dns" {
  count = var.feature_external_dns

  source                  = "git@github.com:example-test-repo/aws-components.git//modules/external-dns?ref=external-dns-0.0.9"
  cluster_name            = var.cluster_name
  account_name            = var.account_name
  psp_enabled             = local.psp_enabled
  service_monitor_enabled = local.service_monitor_enabled
  container_registry      = var.container_registry
  helm_repo_url           = var.helm_repo_url
  k8s_namespace_labels    = var.k8s_namespace_labels

  depends_on = [module.monitoring]
}

module "istio-servicemesh-operator" {
  count = var.feature_istio_servicemesh

  source               = "git@github.com:example-test-repo/aws-components.git//modules/istio-servicemesh?ref=istio-operator-0.0.9"
  k8s_namespace_labels = var.k8s_namespace_labels
  cluster_name         = var.cluster_name
  ingress_class        = local.internal_ingress_class
  container_registry   = var.container_registry
  private_hosted_zone  = local.private_hosted_zone

  depends_on = [module.external-dns]
}

module "metrics-server" {
  count = var.feature_metrics_server

  source             = "git@github.com:example-test-repo/aws-components.git//modules/metrics-server?ref=metrics-server-0.0.3"
  container_registry = var.container_registry

  depends_on = [module.eks-workers]
}

module "beats" {
  count = var.feature_beats

  source               = "git@github.com:example-test-repo/aws-components.git//modules/beats?ref=beats-0.0.4"
  feature_metricbeat   = var.feature_metricbeat
  feature_filebeat     = var.feature_filebeat
  cluster_name         = var.cluster_name
  logstash_port        = var.logstash_port
  prometheus_period    = var.beats_prometheus_period
  account_name         = var.account_name
  helm_repo            = var.helm_repo_url
  container_registry   = var.container_registry
  k8s_namespace_labels = var.k8s_namespace_labels

  depends_on = [module.eks-workers]
}

module "cluster-autoscaler" {
  count = var.feature_cluster_autoscaler

  source                  = "git@github.com:example-test-repo/aws-components.git//modules/cluster-autoscaler?ref=cluster-autoscaler-0.0.2"
  cluster_name            = var.cluster_name
  account_name            = var.account_name
  psp_enabled             = local.psp_enabled
  service_monitor_enabled = local.service_monitor_enabled
  container_registry      = var.container_registry
  helm_repo_url           = var.helm_repo_url

  depends_on = [module.eks-workers]
}
