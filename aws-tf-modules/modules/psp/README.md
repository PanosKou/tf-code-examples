# Pod Security Policies

This module adds pod security policeies to the cluster and removed some of the default PSPs created by AWS when the EKS cluster was provisioned.

# Installation

The PSPs are installed as a helm chart in `kube-system` namespace

There are two PSPs

# epaas.privileged

Pods that run with this policy are running as if there were no policy in place. It is very open and should not be used generally.

By default, several `kube-system` pods are associated with privilaged policy. These pods are run as daemonsets on the eks worker nodes and require eleveanted permissions to allow worker nodes to join the cluster and route traffic appropriatly. 

# z-epaas.restricted

Unless otherwise associated to a PSP, all pods will run with this policy. It acts as a catch all when no other PSP matches. It is associated with all authenticated users. The reason to prefix this policy with a `z` is to control the ordering. PSPs are applied in the order in which they are defined in cases when there is no exact match that would "not" mutate the pod. 

# Association of PSPs to a pod

The standard approach is for cluster adminstrators to create a binding between the service account used by a pod and the policy.


# References

PSPs are documented here: https://kubernetes.io/docs/concepts/policy/pod-security-policy/ 