# EKS VPC-CNI Module

This module will perform the required steps in order to allow pods to  use a secondary CIDR range for their cluster address space as per the [AWS documentation](https://aws.amazon.com/premiumsupport/knowledge-center/eks-multiple-cidr-ranges/]).

This module needs to be run after the EKS master process has been deployed but before any worker nodes. The configuration should work with managed and unmanaged node groups via the aws-node daemonset. Any nodes deployed before the configuration was modified will need to be recycled.

### About the AWS Native VPC-CNI

Conventional kubernetes networking either uses an overlay network like VXLAN, or BGP peering to route pod-to-pod traffic over the attached subnet. This means that the cluster network traffic which containers use is never exposed directly to the external network.

VXLAN makes use of Mac-in-IP packet encapsulation (layer-2 MAC frames are encapsluted in one or more UDP packets).

On AWS, encapsulation is already taking place at the hardware level when using AWS Elastic Network Interfaces (ENI) inside a VPC. By using native AWS networking it removes the need for secondary software encapsulation.

Using AWS native networking also allows the use of [security groups for pods](https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html), this is currently in rudimentary form and security groups used by pods must be defined outside the cluster before being used in network policies.

By using real IP addresses for pods it is also possible to configure the AWS Application Load Balancer (ALB) to comminicate directly with the pods, using "IP" [traffic mode](https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html). This means that inbound connections can be connected directly to the pod, bypassing the traditional nodePort and associated kube-proxy NAT. This is more efficient and scalable but should be carefully considered before use (ALB in IP mode is not compatible with k8s [service topology](https://kubernetes.io/docs/concepts/services-networking/service-topology/)).

### Why use a secondary subnet for k8s pod addressing?

By default, the VPC-CNI also uses the host IP CIDR for pod networking. The host will pre-allocate an entire ENI's IP capacity, allocating more ENIs if required up to the maximum [capcity of the host](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-eni.html#AvailableIpPerENI). This means that on networks where private subnets are limited to /24 networks, IP addresses can be quickly exhausted - even on small deployments.

As the cluster address space is only used within the cluster, it is a waste to allocate pods routable network addresses when they are not needed. When pods communicate to the outside world they do so via kube-proxy which uses iptables to NAT the internal address to an external one.

Wouldn't it be great if we could use a different range for pod networking, just like in traditional CNIs. Thankfully AWS-CNI allows for this.

By making use of a non-routable address range from the IETF [RFC6598](https://tools.ietf.org/html/rfc6598) range (which is for use within a carrier-network and never exposed externally) we can allocate many more IP addresses than would normally be available in a subnet.

We intend to allow a /19 network per AZ, allowing for up to 24,570 addresses for pods to use. IP addresses are still limited up to the capacity of the instance ENI allocation.

### What if I want to allocate a range from the host network to a pod?

Sometimes pods may require addresses from the real host network in order to function. An example of this would be pods associate with the setup of initial networking like aws-node and/or calico-node.

This is fully supported, in order to start a pod within the host network simply add the following annotations to the pod's spec:

``` yaml
spec: 
  hostNetwork: true
```

This annotation is not specific to VPC-CNI and is documented in the kubernetes documentation [here](https://kubernetes.io/docs/concepts/policy/pod-security-policy/#host-namespaces).

