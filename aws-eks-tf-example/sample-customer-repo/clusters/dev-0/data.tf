data "aws_eks_cluster" "cluster" {
  name = module.aws-eks.cluster_id
}

data "aws_eks_cluster_auth" "kubernetes_token" {
  name = module.aws-eks.cluster_id
}

data "aws_kms_key" "key" {
  key_id = "alias/dev-client-kms-key"
}
