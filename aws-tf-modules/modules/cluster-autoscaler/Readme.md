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
| account-name | NBS Account Name | `string` | n/a | yes |
| cluster-name | Name of the EKS cluster | `string` | n/a | yes |
| psp-enabled | Flag to indicate if psp is enabled | `string` | n/a | yes |
| service-monitor-enabled  | Flag to indicate if service monitor is enabled | `string` | n/a | yes |
| helm\_repo\_url | Helm Repo url | `string` |  | yes |
| container_registry | Container registry | `string` |  | yes |

## Outputs

No output.


## Manual Testing of Cluster Scaling

The cluster scaling can take around half hour so its best not to include BDD tests for testing cluster autoscaling as it will hold the pipeline for long.

In absence of BDD tests for autoscaling, autoscaling can be tested using following steps:

1. Login to cluster.
2. Create a YAML file locally with following contents:

```
apiVersion: apps/v1

kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 100
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: docker-remote.artifactory.aws.nbscloud.co.uk:443/hashicorp/http-echo
        args:
        - "-text=Hello World!"
```
3. Apply this deployment to the cluster with:

    kubectl apply -f <filename with contents above>

    This will create 100 pods in the cluster.

4. While pods are being deployed from above, eventually pods will go into pending state due to there not being enough nodes. At this point the autoscaler will kick in and provision new node. This proves the autoscaling works.


