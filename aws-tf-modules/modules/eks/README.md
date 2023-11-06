# Overview
This module creates EKS (cluster) on AWS.

## Branch strategy

On a successful merge to master, the pipeline will automatically tag and publish the new version of the repo. To correctly increment the SemVer, please use the following branch naming conventions:
* *-major (to increment to the next major release)
* *-minor (to increment to the next minor release)
* *-patch (to increment to the next patch release)

IMPORTANT: Branch names that do not match this convention will default to releasing a new minor release.

## Usage example - On Demand Instances
### for more info look at workers-group-defaults in `locals.tf`
```hcl

module "my-eks" {
  source = "git@github.com:example-test-repo/terraform-aws-eks.git?ref=${MY-TAG}"

  account-name    = "my-nbs-account"
  cluster-name    = "my-cluster"
  cluster-version = "1.24"
  feature-eks     = 1
  worker-groups = [
    {
      "name" : "k8s-worker-blue",
      "worker-version" : "1.15.11",
      "instance-type" : "t3.medium",
      "asg-desired-capacity" : "3",
      "asg-max-size" : "3",
      "asg-min-size" : "3",
    },
    {
      "name" : "k8s-worker-green",
      "worker-version" : "1.16.8",
      "instance-type" : "t3a.large",
      "asg-desired-capacity" : "0",
      "asg-max-size" : "0",
      "asg-min-size" : "0",
    }
  ]
  subnets-ids                   = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc-id                        = "vpc-1234556abcdef"
  tf-role                       = "app-creator"
  vpc-tier-private-cidr-primary = ["10.0.0.0/14"]
}
```

## Usage example - Spot Instances
### for more info look at workers-group-defaults in `locals.tf`

```hcl

module "my-eks" {
  source = "git@github.com:example-test-repo/terraform-aws-eks.git?ref=${MY-TAG}"

  account-name    = "my-account"
  cluster-name    = "my-cluster"
  cluster-version = "1.24"
  feature-eks     = 1
  worker-groups = [
    {
      "name" : "k8s-worker-blue",
      "worker-version" : "1.15.11",
      "override-instance-types" : ["m5.large", "m5a.large", "m5d.large", "m5ad.large"],
      "spot-instance-pools"  : "3",
      "asg-desired-capacity" : "3",
      "asg-max-size" : "3",
      "asg-min-size" : "3",
    },
    {
      "name" : "k8s-worker-green",
      "worker-version" : "1.16.8",
      "override-instance-types" : null,
      "spot-instance-pools" : "0"
      "asg-desired-capacity" : "0",
      "asg-max-size" : "0",
      "asg-min-size" : "0",
    }
  ]
  subnets-ids                   = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc-id                        = "vpc-1234556abcdef"
  tf-role                       = "app-creator"
  vpc-tier-private-cidr-primary = ["10.0.0.0/14"]
}
```
## Usage example - Mixed Instances
### for more info look at workers-group-defaults in `locals.tf`

```hcl

module "my-eks" {
  source = "git@github.com:example-test-repo/terraform-aws-eks.git?ref=${MY-TAG}"

  account-name    = "my-account"
  cluster-name    = "my-cluster"
  cluster-version = "1.24"
  feature-eks     = 1
  worker-groups = [
    {
      "name" : "k8s-worker-blue",
      "worker-version" : "1.15.11",
      "on-demand-allocation-strategy" : "prioritized",
      "on-demand-base-capacity" : "3",
      "override-instance-types" : ["m5.large", "m5a.large", "m5d.large", "m5ad.large"],
      "spot-instance-pools"     : "3",
      "asg-desired-capacity" : "5",
      "asg-max-size" : "5",
      "asg-min-size" : "5",
    },
    {
      "name" : "k8s-worker-green",
      "worker-version" : "1.16.8",
      "on-demand-allocation-strategy" : "prioritized",
      "on-demand-base-capacity" : "0",
      "override-instance-types" : null,
      "spot-instance-pools"     : "0",
      "asg-desired-capacity" : "0",
      "asg-max-size" : "0",
      "asg-min-size" : "0",
    }
  ]
  subnets-ids                   = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  vpc-id                        = "vpc-1234556abcdef"
  tf-role                       = "app-creator"
  vpc-tier-private-cidr-primary = ["10.0.0.0/14"]
}

```
### Please refer following example table for Mixed Instances Scaling
| Example: Scaling Behavior             |                                                           |    |    |    |
|---------------------------------------|-----------------------------------------------------------|----|----|----|
| Instances Distribution                | Total Number of Running Instances Across Purchase Options |    |    |    |
|  Total Instances Launched                                     | 10                                                        | 20 | 30 | 40 |
| Example 1                             |                                                           |    |    |    |
| On-Demand base: 10                    | 10                                                        | 10 | 10 | 10 |
| On-Demand percentage above base: 50%  | 0                                                         | 5  | 10 | 15 |
| Spot percentage: 50%                  | 0                                                         | 5  | 10 | 15 |
| Example 2                             |                                                           |    |    |    |
| On-Demand base: 0                     | 0                                                         | 0  | 0  | 0  |
| On-Demand percentage above base: 0%   | 0                                                         | 0  | 0  | 0  |
| Spot percentage: 100%                 | 10                                                        | 20 | 30 | 40 |
| Example 3                             |                                                           |    |    |    |
| On-Demand base: 0                     | 0                                                         | 0  | 0  | 0  |
| On-Demand percentage above base: 60%  | 6                                                         | 12 | 18 | 24 |
| Spot percentage: 40%                  | 4                                                         | 8  | 12 | 16 |
| Example 4                             |                                                           |    |    |    |
| On-Demand base: 0                     | 0                                                         | 0  | 0  | 0  |
| On-Demand percentage above base: 100% | 10                                                        | 20 | 30 | 40 |
| Spot percentage: 0%                   | 0                                                         | 0  | 0  | 0  |
| Example 5                             |                                                           |    |    |    |
| On-Demand base: 12                    | 10                                                        | 12 | 12 | 12 |
| On-Demand percentage above base: 0%   | 0                                                         | 0  | 0  | 0  |
| Spot percentage: 100%                 | 0                                                         | 8  | 18 | 28 |


# Inputs

The following inputs and outputs have been mapped with [terraform-docs](https://github.com/segmentio/terraform-docs). If you cause a change to either then please rerun and update the generated list below, with e.g. 
`terraform-docs markdown table ./`

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| local | n/a |
| null | n/a |
| random | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default                                                                                                      | Required |
|------|-------------|------|--------------------------------------------------------------------------------------------------------------|:--------:|
| account-name | NBS Account Name | `string` | n/a                                                                                                          | yes |
| central-vpn-cidr-blocks | VPN cidr blocks to access eks | `list(string)` | <pre>[<br>  "10.160.68.0/24",<br>  "10.160.69.0/24",<br>  "10.160.70.0/24"<br>]</pre>                        | no |
| cluster-enabled-log-types | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| cluster-log-kms-key-id | If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html) | `string` | `""`                                                                                                         | no |
| cluster-log-retention-in-days | Number of days to retain log events. Default retention - 30 days. | `number` | `30`                                                                                                         | no |
| cluster-name | Name of the EKS cluster to be created | `string` | `""`                                                                                                         | no |
| cluster-role | Custom IAM role to be used by EKS cluster..if not provided..{var.account-name}-role-eks-cluster will be used | `string` | `""`                                                                                                         | no |
| cluster-sg | Custom SG role to be used by EKS cluster..if not provided ..{var.account-name}-role-eks-cluster will be used | `string` | `""`                                                                                                         | no |
| cluster-version | Kubernetes version to use for the EKS cluster. | `string` | `"1.24"`                                                                                                     | no |
| endpoint-public-access | Whether to enable public endpoint access to the API or not. | `bool` | `false`                                                                                                      | no |
| feature-eks | Feature falg to enable the module | `number` | `1`                                                                                                          | no |
| provisioning-account-cidr | CIDR blocks to access the cluster from provisioning account | `list(string)` | <pre>[<br>  "10.160.52.0/24",<br>  "10.160.53.0/24",<br>  "10.160.54.0/24"<br>]</pre>                        | no |
| ssh-public-key | SSH Pubkey to for ssh access to worker nodes.. if not specified key named {var.cluster_name}-eks-workers will be created and its details are stored in secrets manager | `string` | `""`                                                                                                         | no |
| subnet-ids | Subnets ids for worker nodes | `list(string)` | n/a                                                                                                          | yes |
| tags | Tags for the all the resources created in the module | `map(string)` | `{}`                                                                                                         | no |
| tf-role | Role used by terraform for null\_resources | `string` | `"app-creator"`                                                                                              | no |
| vpc-id | ID of the VPC where the cluster would be created | `string` | n/a                                                                                                          | yes |
| vpc-tier-private-cidr-primary | VPC CIDR | `list(string)` | n/a                                                                                                          | yes |
| worker-groups | List of worker groups with each its own ASG and config | `list` | n/a                                                                                                          | yes |

## Outputs

| Name | Description |
|------|-------------|
| config-map-aws-auth | aws auth configmap |
| kubeconfig | kubeconfig |
| secret-manager-private-key-name | SSH private key secret name in aws secret manager |
| secret-manager-public-key-name | SSH private key secret name in aws secret manager |