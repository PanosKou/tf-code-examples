# Aws Calico Policy Engine and Global Network Polices

The module is responsible for setting up Aws calico policy engine along with Global network policies 

    default-deny      : The default deny across whole cluster except control plane traffic (kube-system namespace)

    default-allow-dns : The policy allows access for DNS resolution, which avoids defining per namespace policy for dns resolution

## Providers

| Name | Version |
|------|---------|
| helm | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| chart\_version | Helm chart version | `string` | `"0.3.4"` | no |
| helm\_repo\_url | Helm Repo url | `string` | `""` | yes |

## Outputs

No output.

