## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| helm | n/a |
| kubernetes | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| account\_name | NBS Account Name | `string` | n/a | yes |
| chart\_version | Helm chart version | `string` | `"3.7.0"` | no |
| cluster\_name | Name of the EKS cluster | `string` | n/a | yes |
| container\_registry | Artifactory repository for storing docker containers used by core components on the cluster | `string` | n/a | yes |
| helm\_repo\_url | Helm Repo url | `string` | n/a | yes |
| k8s\_namespace\_labels | K8S Namespace labels | `map` | `{}` | no |
| namespace | External DNS Namespace | `string` | `"external-dns"` | no |
| psp\_enabled | Should PSPs be enabled in helm chart? Only valid if PSPs are enabled in cluster | `bool` | `false` | no |
| service\_monitor\_enabled | Should service monitor be enabled? Only valid if prometheus is also enabled | `bool` | `false` | no |

## Outputs

No output.

