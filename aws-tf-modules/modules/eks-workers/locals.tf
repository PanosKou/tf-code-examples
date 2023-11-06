locals {
  workers_group_defaults = {
    name                          = ""              # Name of the worker group.
    tags                          = []              # A list of map defining extra tags to be applied to the worker group autoscaling group.
    ami-id                        = ""              # AMI ID for the eks linux based workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI based on platform.
    ami-id-windows                = ""              # AMI ID for the eks windows based workers. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI based on platform.
    asg-desired-capacity          = "1"             # Desired worker capacity in the autoscaling group and changing its value will not affect the autoscaling group's desired capacity because the cluster-autoscaler manages up and down scaling of the nodes. Cluster-autoscaler add nodes when pods are in pending state and remove the nodes when they are not required by modifying the desirec-capacity of the autoscaling group. Although an issue exists in which if the value of the asg-min-size is changed it modifies the value of asg-desired-capacity.
    asg-max-size                  = "3"             # Maximum worker capacity in the autoscaling group.
    asg-min-size                  = "1"             # Minimum worker capacity in the autoscaling group. NOTE: Change in this paramater will affect the asg-desired-capacity, like changing its value to 2 will change asg-desired-capacity value to 2 but bringing back it to 1 will not affect the asg-desired-capacity.
    asg-force-delete              = false           # Enable forced deletion for the autoscaling group.
    asg-initial-lifecycle-hooks   = []              # Initital lifecycle hook for the autoscaling group.
    asg-recreate-on-change        = false           # Recreate the autoscaling group when the Launch Template or Launch Configuration change.
    default-cooldown              = ""              # The amount of time, in seconds, after a scaling activity completes before another scaling activity can start.
    health-check-grace-period     = ""              # Time in seconds after instance comes into service before checking health.
    instance-type                 = "m4.large"      # Size of the workers instances.
    spot-price                    = ""              # Cost of spot instance.
    placement-tenancy             = ""              # The tenancy of the instance. Valid values are "default" or "dedicated".
    root-volume-size              = "100"           # root volume size of workers instances.
    root-volume-type              = "gp2"           # root volume type of workers instances, can be 'standard', 'gp2', or 'io1'
    root-iops                     = "0"             # The amount of provisioned IOPS. This must be set with a volume-type of "io1".
    key-name                      = ""              # The key name that should be used for the instances in the autoscaling group
    pre-userdata                  = ""              # userdata to pre-append to the default userdata.
    userdata-template-file        = ""              # alternate template to use for userdata
    userdata-template-extra-args  = {}              # Additional arguments to use when expanding the userdata template file
    bootstrap-extra-args          = ""              # Extra arguments passed to the bootstrap.sh script from the EKS AMI (Amazon Machine Image).
    additional-userdata           = ""              # userdata to append to the default userdata.
    ebs-optimized                 = true            # sets whether to use ebs optimization on supported types.
    enable-monitoring             = true            # Enables/disables detailed monitoring.
    public-ip                     = false           # Associate a public ip address with a worker
    kubelet-extra-args            = ""              # This string is passed directly to kubelet if set. Useful for adding labels or taints.
    subnets                       = []              # A list of subnets to place the worker nodes in. i.e. ["subnet-123", "subnet-456", "subnet-789"]
    intra-subnets                 = []              # A list intra subnets to be used by pods running on the worker nodes
    additional-security-group-ids = []              # A list of additional security group ids to include in worker launch config
    protect-from-scale-in         = false           # Prevent AWS from scaling in, so that cluster-autoscaler is solely responsible.
    iam-instance-profile-name     = ""              # A custom IAM instance profile name. Used when manage-worker-iam-resources is set to false. Incompatible with iam-role-id.
    iam-role-id                   = ""              # A custom IAM role id. Incompatible with iam-instance-profile-name.  Literal local.default-iam-role-id will never be used but if iam-role-id is not set, the local.default-iam-role-id interpolation will be used.
    suspended-processes           = ["AZRebalance"] # A list of processes to suspend. i.e. ["AZRebalance", "HealthCheck", "ReplaceUnhealthy"]
    target-group-arns             = []              # A list of Application LoadBalancer (ALB) target group ARNs to be associated to the autoscaling group
    enabled-metrics               = []              # A list of metrics to be collected i.e. ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity"]
    placement-group               = ""              # The name of the placement group into which to launch the instances, if any.
    service-linked-role-arn       = ""              # Arn of custom service linked role that Auto Scaling group will use. Useful when you have encrypted EBS
    termination-policies          = []              # A list of policies to decide how the instances in the auto scale group should be terminated.
    platform                      = "linux"         # Platform of workers. either "linux" or "windows"
    additional-ebs-volumes        = []              # A list of additional volumes to be attached to the instances on this Auto Scaling group. Each volume should be an object with the following: block-device-name (required), volume-size, volume-type, iops, encrypted, kms-key-id (only on launch-template), delete-on-termination. Optional values are grabbed from root volume or from defaults
    # Settings for launch templates
    root-block-device-name            = ""         # Root device name for workers. If non is provided, will assume default AMI was used.
    root-kms-key-id                   = ""         # The KMS key to use when encrypting the root storage device
    launch-template-version           = "$Latest"  # The lastest version of the launch template to use in the autoscaling group
    launch-template-placement-tenancy = "default"  # The placement tenancy for instances
    launch-template-placement-group   = ""         # The name of the placement group into which to launch the instances, if any.
    root-encrypted                    = true       # Whether the volume should be encrypted or not
    eni-delete                        = true       # Delete the Elastic Network Interface (ENI) on termination (if set to false you will have to manually delete before destroying)
    cpu-credits                       = "standard" # T2/T3 unlimited mode, can be 'standard' or 'unlimited'. Used 'standard' mode as default to avoid paying higher costs
    market-type                       = ""
    # Settings for launch templates with mixed instances policy
    override-instance-types                  = []             # ["m5.large", "m5a.large", "m5d.large", "m5ad.large"] # A list of override instance types for mixed instances policy
    on-demand-allocation-strategy            = ""             # Strategy to use when launching on-demand instances. Valid values: prioritized.
    on-demand-base-capacity                  = "0"            # Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances
    on-demand-percentage-above-base-capacity = "0"            # Percentage split between on-demand and Spot instances above the base on-demand capacity.. Minimum value of 0. Maximum value of 100. 100 means 100% all on demand instances above on-demand-base-capacity and 0% spot instances
    spot-allocation-strategy                 = "lowest-price" # Valid options are 'lowest-price' and 'capacity-optimized'. If 'lowest-price', the Auto Scaling group launches instances using the Spot pools with the lowest price, and evenly allocates your instances across the number of Spot pools. If 'capacity-optimized', the Auto Scaling group launches instances using Spot pools that are optimally chosen based on the available Spot capacity.
    spot-instance-pools                      = 10             # "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify."
    spot-max-price                           = ""             # Maximum price per unit hour that the user is willing to pay for the Spot instances. Default is the on-demand price
    max-instance-lifetime                    = 0              # Maximum number of seconds instances can run in the ASG. 0 is unlimited.
  }

  worker_groups = { for worker_group in var.worker_groups : worker_group.name => merge(local.workers_group_defaults, worker_group) }

  asg-tags = [
    for item in keys(var.tags) :
    map(
      "key", item,
      "value", element(values(var.tags), index(keys(var.tags), item)),
      "propagate-at-launch", "true"
    )
  ]
  worker-default-version = var.cluster_version
}

locals {
  node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
sleep 100
cat <<EOF > /etc/pki/ca-trust/source/anchors/root_ca.pem
${var.nbs_management_networking_ca_pem}
EOF

cat <<EOF > /etc/pki/ca-trust/source/anchors/NationwideRootCA2.pem
${var.nationwide_root_ca2_pem}
EOF

/usr/bin/update-ca-trust

/etc/eks/bootstrap.sh --apiserver-endpoint '${var.cluster_endpoint}' --b64-cluster-ca '${var.cluster_ca_b64}' '${var.cluster_name}'
USERDATA
}

locals {
  secret_manager_private_key_name = "${var.cluster_name}-eks-workers-key-pair-private-${formatdate("DDMMYYYY-hhmmss", time_static.current_time.rfc3339)}" # SSH private key secret name in aws secret manager
  secret_manager_public_key_name  = "${var.cluster_name}-eks-workers-key-pair-public-${formatdate("DDMMYYYY-hhmmss", time_static.current_time.rfc3339)}"  # SSH public key secret name in aws secret manager
}