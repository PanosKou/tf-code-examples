locals {

  default_epass_roles = [
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_name}-eks-admin"
      username = "app-creator:{{SessionName}}"
      groups = tolist(concat(
        [
          "system:masters"
        ]
      ))
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_name}-eks-read"
      username = "epaas-read:{{SessionName}}"
      groups = tolist(concat(
        [
          "epaas:read"
        ]
      ))
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.account_name}-eks-executor"
      username = "epaas-executor:{{SessionName}}"
      groups = tolist(concat(
        [
          "epaas:executor"
        ]
      ))
    }
  ]

  default_map_roles = [
    {
      rolearn  = data.aws_iam_role.node_role.arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = tolist(concat(
        [
          "system:bootstrappers",
          "system:nodes",
        ]
      ))
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/infra-creator"
      username = "infra-creator:{{SessionName}}"
      groups = tolist(concat(
        [
          "system:masters"
        ]
      ))
    },
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/app-creator"
      username = "app-creator:{{SessionName}}"
      groups = tolist(concat(
        [
          "system:masters"
        ]
      ))
    }
  ]
}

locals {
  aws_auth_map_roles = var.enable_default_rbac_roles == 1 ? distinct(concat(local.default_epass_roles, local.default_map_roles, var.custom_rbac_mappings)) : distinct(concat(local.default_map_roles, var.custom_rbac_mappings))
}