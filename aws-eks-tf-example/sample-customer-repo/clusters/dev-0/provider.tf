provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn     = "arn:aws:iam::<ACCOUNT_ID>:role/<ACCOUNT_NAME>-role-app-creator"
    session_name = "TerraformAssumeRole"
  }

  shared_credentials_file = ".credentials.aws"
  profile                 = "default"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.kubernetes_token.token
  load_config_file       = "false"
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.kubernetes_token.token
  }
}
