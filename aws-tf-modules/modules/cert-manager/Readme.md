## Providers

| Name | Version |
|------|---------|
| helm | n/a |
| kubernetes | n/a |
| null | n/a |
| template | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| chart\_version | Cert Manager chart version | `string` | `"v1.0.4"` | no |
| container\_registry | Artifactory repository for storing docker containers used by core components on the cluster | `string` | n/a | yes |
| helm\_repo\_url | Helm Repo url | `string` | n/a | yes |
| k8s\_namespace\_labels | K8S Namespace labels | `map` | `{}` | no |
| namespace | Cert Manager Namespace | `string` | `"cert-manager"` | no |
| nbs\_management\_networking\_ca\_pem | NBS Management Networking CA in PEM format | `string` | n/a | yes |
| psp\_enabled | Should PSPs be enabled in helm chart? Only valid if PSPs are enabled in cluster | `bool` | `false` | no |
| service\_monitor\_enabled | Should service monitor be enabled? Only valid if prometheus is also enabled | `bool` | `false` | no |
| vault\_addr | vault instance address | `any` | n/a | yes |
| vault\_backend\_namespace | Namespace in vault backend | `any` | n/a | yes |
| vault\_mount\_path | Path to valut role the k8s sa assumes | `any` | n/a | yes |
| vault\_path | Path to pki vault role | `any` | n/a | yes |
| vault\_role | Vault role the k8s sa assumes | `any` | n/a | yes |

## Outputs

No output.

