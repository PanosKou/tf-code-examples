resource "aws_autoscaling_group" "workers" {
  for_each = local.worker_groups
  name_prefix = join(
    "-",
    compact(
      [
        var.cluster_name, each.value.name,
        each.value["asg-recreate-on-change"] ? random_pet.workers[each.value.name].id : ""
      ]
    )
  )

  desired_capacity    = each.value["asg-desired-capacity"]
  max_size            = each.value["asg-max-size"]
  min_size            = each.value["asg-min-size"]
  force_delete        = each.value["asg-force-delete"]
  vpc_zone_identifier = var.subnet_ids

  dynamic mixed_instances_policy {
    iterator = item
    for_each = ((length(local.worker_groups[each.key]["override-instance-types"]) != 0) || (lookup(local.worker_groups[each.key], "on-demand-allocation-strategy", "") != "")) ? list(each.value) : []

    content {
      instances_distribution {
        on_demand_allocation_strategy            = lookup(item.value, "on-demand-allocation-strategy", "prioritized")
        on_demand_base_capacity                  = item.value["on-demand-base-capacity"]
        on_demand_percentage_above_base_capacity = item.value["on-demand-percentage-above-base-capacity"]

        spot_allocation_strategy = item.value["spot-allocation-strategy"]
        spot_instance_pools      = item.value["spot-instance-pools"]
        spot_max_price           = item.value["spot-max-price"]
      }

      launch_template {
        launch_template_specification {
          launch_template_id = aws_launch_template.workers[each.key].id
          version            = item.value["launch-template-version"]
        }

        dynamic "override" {
          for_each = item.value["override-instance-types"]

          content {
            instance_type = override.value
          }
        }
      }
    }
  }

  dynamic launch_template {
    iterator = item
    for_each = ((length(local.worker_groups[each.key]["override-instance-types"]) != 0) || (lookup(local.worker_groups[each.key], "on-demand-allocation-strategy", "") != "")) ? [] : list(each.value)

    content {
      id      = aws_launch_template.workers[each.key].id
      version = item.value["launch-template-version"]
    }
  }

  tag = concat(
    [
      {
        "key"                 = "Name"
        "value"               = "${var.cluster_name}-${each.value.name}-eks-asg"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "kubernetes.io/cluster/${var.cluster_name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "k8s.io/cluster/${var.cluster_name}"
        "value"               = "owned"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/enabled"
        "value"               = "true"
        "propagate_at_launch" = true
      },
      {
        "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
        "value"               = var.cluster_name
        "propagate_at_launch" = true
      },
    ],
    local.asg-tags,
    lookup(
      each.value,
      "tags",
      {}
    )
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_launch_template" "workers" {
  for_each = local.worker_groups

  name_prefix = "${var.cluster_name}-${each.key}"

  # vpc_security_group_ids = [aws_security_group.node.id]
  vpc_security_group_ids = [var.worker_security_group_id]

  iam_instance_profile {
    name = data.aws_iam_instance_profile.node-profile.name
  }

  image_id = lookup(each.value, "ami-id", "") == "" ? data.aws_ami.eks-nodes[each.key].id : each.value["ami-id"]

  instance_type = each.value["instance-type"]
  key_name      = var.ssh_public_key != "" ? aws_key_pair.EKS[0].key_name : aws_key_pair.key_pair[0].key_name

  user_data = base64encode(local.node-userdata)

  monitoring {
    enabled = each.value["enable-monitoring"]
  }

  dynamic placement {
    for_each = each.value["launch-template-placement-group"] != "" ? [each.value["launch-template-placement-group"]] : []

    content {
      tenancy    = each.value["launch-template-placement-tenancy"]
      group_name = placement.value
    }
  }

  block_device_mappings {
    device_name = lookup(each.value, "root-block-device-name", "") != "" ? each.value["root-block-device-name"] : data.aws_ami.eks-nodes[each.key].root_device_name # TODO fix bug here when AMI passed as variable

    ebs {
      volume_size = each.value["root-volume-size"]
      volume_type = each.value["root-volume-type"]
      iops        = each.value["root-iops"]
      encrypted   = each.value["root-encrypted"]
      kms_key_id  = each.value["root-kms-key-id"]

      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      {
        Name = "${var.cluster_name}-${each.key}-eks-asg"
      },
      var.tags,
    )
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      {
        Name = "${var.cluster_name}-${each.key}-eks-asg"
      },
      var.tags,
    )
  }

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

// Create SSH Key for worker and store it in secrets manager
resource "tls_private_key" "key_pair" {
  count       = (var.ssh_public_key == "") ? 1 : 0
  algorithm   = "RSA"
  ecdsa_curve = "4096"
}

resource "aws_key_pair" "key_pair" {
  count = (var.ssh_public_key == "") ? 1 : 0

  key_name   = "${var.cluster_name}-eks-workers"
  public_key = tls_private_key.key_pair[0].public_key_openssh
}

# generate time resource to be used in null resource
resource "time_static" "current_time" {}

# using null resources to create public key secret to avoid error during destroy as app-creator wont have permission to delete the resources
resource "null_resource" "secret_manager_public" {
  count = (var.ssh_public_key == "") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
    set -x
    assumed_role_details=$(aws sts assume-role \
      --role-arn "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.tf_role}" \
      --role-session-name "TerraformAssumeRole-ssm-public" \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text)

    # Null resources are ran within their own process, therefore safe to set these env vars
    AWS_ACCESS_KEY_ID=$(echo "$${assumed_role_details}" | cut -f1)
    AWS_SECRET_ACCESS_KEY=$(echo "$${assumed_role_details}" | cut -f2)
    AWS_SESSION_TOKEN=$(echo "$${assumed_role_details}" | cut -f3)
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN

    aws secretsmanager create-secret --name "${var.cluster_name}-eks-workers-key-pair-public-${formatdate("DDMMYYYY-hhmmss", time_static.current_time.rfc3339)}" \
      --description "public part of ssh key pair for eks workers" \
      --secret-string "${tls_private_key.key_pair[0].public_key_pem}" \
      --tags Key="Name",Value="${var.cluster_name}-eks-workers-key-pair-public-${formatdate("DDMMYYYY-hhmmss", time_static.current_time.rfc3339)}" \
      --region "${data.aws_region.current.name}"
EOF
  }
}

# using null resources to create private key secret to avoid error during destroy as app-creator wont have permission to delete the resources
resource "null_resource" "secret_manager_private" {
  count = (var.ssh_public_key == "") ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
    set -x
    assumed_role_details=$(aws sts assume-role \
      --role-arn "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.tf_role}" \
      --role-session-name "TerraformAssumeRole-ssm-private" \
      --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
      --output text)

    # Null resources are ran within their own process, therefore safe to set these env vars
    AWS_ACCESS_KEY_ID=$(echo "$${assumed_role_details}" | cut -f1)
    AWS_SECRET_ACCESS_KEY=$(echo "$${assumed_role_details}" | cut -f2)
    AWS_SESSION_TOKEN=$(echo "$${assumed_role_details}" | cut -f3)
    export AWS_ACCESS_KEY_ID
    export AWS_SECRET_ACCESS_KEY
    export AWS_SESSION_TOKEN

    aws secretsmanager create-secret --name "${local.secret_manager_private_key_name}" \
      --description "private part of ssh key pair for eks workers" \
      --secret-string "${tls_private_key.key_pair[0].private_key_pem}" \
      --tags Key="Name",Value="${local.secret_manager_private_key_name}" \
      --region "${data.aws_region.current.name}"
EOF
  }
}

resource "aws_key_pair" "EKS" {
  count      = (var.ssh_public_key != "") ? 1 : 0
  key_name   = "${var.cluster_name}-EKS"
  public_key = var.ssh_public_key
}

resource "random_pet" "workers" {
  for_each = local.worker_groups

  separator = "-"
  length    = 2

  keepers = {
    lt_name = join(
      "-",
      compact(
        [
          aws_launch_template.workers[each.key].name,
          aws_launch_template.workers[each.key].latest_version
        ]
      )
    )
  }
}
