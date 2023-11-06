
# Istio Service Mesh: Operator + Configuration

This is a **two-part provisioning** process following the decided
[Installation Option](https://docs.nationwidebuilding.luminatesec.com/docs/epaas-eks/product-engineering/decisions/servicemesh-install/)

### Providers

| Name | Version |
|------|---------|
| helm | n/a |

This provisioning process of the Istio Operator, it is inert on install.

The `Kind:IstioOperator` configuration called `istio-profile-v1` is what features the individual components. This is what will be installed as part of ***the service mesh** and consumes resources within  the Kubernetes Cluster. (Ensure cluster nodepool autoscaling is functioning)

### Components

The new installer is intended to be modular and very explicit about what is installed. It has
far more steps than the Istio installer - but each step is smaller and focused on a specific
feature, and can be performed by different people/teams at different times.

It is strongly recommended that different namespaces are used, with different service accounts.
In particular access to the security-critical production components (root CA, policy, control)
should be locked down and restricted.  The new installer allows multiple instances of
policy/control/telemetry - so testing/staging of new settings and versions can be performed
by a different role than the prod version.

The intended users of this repo are users running Istio in production who want to select, tune
and understand each binary that gets deployed, and select which combination to use.

## 1. Istio-Operator
**Standardised Helm install method of a managed CRD being Istio Operator** - This small chart has been extracted from the initial Istio service Mesh release. 
Initial Service Mesh Operator version `v1.7.4`
This Chart has been re-tarred as `istio-operator-1.7.4.tar` and pushed into the public repo (managed by ePaaS) as follows;

```
curl -k -H 'X-JFrog-Art-Api:<API_KEY>' -T istio-operator-1.7.4.tar \ 
"https://ccoe-docker-rel-local.artifactory.aws.nbscloud.co.uk/artifactory/epaas-helm-rel-local/istio-operator-1.7.4"
```

All components are Terraform > Helm-installed into `istio-operator` namespace.

It is deemed a generic non-managed piece of configuration, an artifact to be kept outside the actual module configuration repository.

## 2. Istio service-mesh components
**The Istio-operator-installed components & configuration**. 
This defines the *actual* service mesh components and their configuration `istio-operator` will pull down and configure.
This is kept as a standard Helm Chart `Istio-servicemesh-profile` and counted as a separate step within the terraform provisioning process.
At present it features the standard YAML manifest in `Istio-servicemesh-profile/templates` which can be tuned directly or create a separate `values.yaml` to template it out further. The latter is debatable to be delivering a good return on effort.

The YAML `Kind:IstioOperator` that features all the components and configuration is installed via Terraform > Helm-installed into  `istio-system` namespace.



## Requirements and Options
Observe that all service mesh components are installed into `istio-system` namespace, with that `IstioOperator` configuration called `istio-profile-v1`. 

Each component in the new installer is optional. Users can install the component defined in the new installer, use the equivalent component in istio-system, configured with the official installer, or use a different version or implementation.

For example you may use your own Prometheus and Grafana installs, or use components that are centrally managed and running in a different cluster.

Should Tenant or multi-tenant requirements arise, additional separate `Kind:IstioOperator` could be created to match individual use-case like `istio-profile-PRODUCT-A` featuring a fine grained list of configurations alongside additional extensions such as Kiali, Prometheus or distributed packet tracing



## Local Chart Testing
If you wish to test the manual-chart-tarball locally, just override the `chart` reference to the local path as follows

```
resource "helm_release" "istio_operator" {
...
chart       = "${path.module}/charts/istio-operator"
...
}
```

## Manual Cleanup

```
kubectl -n istio-system delete istiooperator istio-profile-v1
# delete the helm version of the release, as appropriate
sh.helm.release.v1.istio-operator.v1
# cleanup istio-system
kubectl delete ns istio-system
# remove all istio-operator references
kubectl delete ClusterRoleBinding istio-operator 
kubectl delete ClusterRole istio-operator 
kubectl delete ns istio-operator
```

## Network Policy Requirements
In order for workloads to join the service-mesh, the source namespaces will need to be modified to allow network access to the istiod control plane and ingress from istio-ingressgateway.

####  An example of these requirements (tested on the istio bookinfo app):


```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-istio-system
spec:
  egress:
  - ports:
    - port: 15021
      protocol: TCP
    - port: 80
      protocol: TCP
    - port: 443
      protocol: TCP
    - port: 15012
      protocol: TCP
    to:
    - namespaceSelector: {}
  podSelector: {}
  policyTypes:
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-istio-ingressgateway
spec:
  ingress:
  - ports:
    - port: 9080
      protocol: TCP
  podSelector: {}
  policyTypes:
  - Ingress
---
# This should be modified for exact workload requirements.
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
spec:
  egress:
  - to:
    - podSelector: {}
  ingress:
  - from:
    - podSelector: {}
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ---
  # Allow Prometheus to scrape istio-proxy metrics
  apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus
spec:
  ingress:
  - ports:
    - port: 15020
      protocol: TCP
    - port: 15090
      protocol: TCP
  - from:
    - podSelector:
        matchLabels:
          app: prometheus
  podSelector: {}
  policyTypes:
  - Ingress
  ```
## Kiali Authentication

Kiali has been installed with "token" authentication method. You will need a valid kubernetes RBAC token to login. You can create a token with the following aws cli command (replace \<CLUSTER NAME\> with your cluster name):

```bash
aws --region eu-west-2 eks get-token --cluster-name <CLUSTER NAME> | jq -r ' .status.token '
```