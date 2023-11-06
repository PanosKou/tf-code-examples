module "aws-eks" {
  source       = "git@github.com:example-test-repo/aws-eks.git//module/aws-eks?ref=1.18.34"
  account_name = "dev"
  cluster_name = "dev-6"
  worker_groups = [
    {
      "name" : "workers",
      "worker-version" : "1.18.8",
      "instance-type" : "t3.medium",
      "asg-desired-capacity" : "3",
      "asg-max-size" : "5",
      "asg-min-size" : "3",
    }
  ]
  cluster_encryption_key_arn = data.aws_kms_key.key.arn
  feature_eks                = 1
  feature_eks_custom_vpc_cni = 0
  feature_aws_calico         = 1
  feature_eks_workers        = 1
  feature_vault_auth         = 0
  feature_storage_class      = 1
  feature_ingress_nginx      = 1
  feature_monitoring         = 1
  feature_cert_manager       = 1
  feature_external_dns       = 1
  feature_metrics_server     = 1
  feature_istio_servicemesh  = 1
  feature_metricbeat         = 0
  feature_filebeat           = 0
}
