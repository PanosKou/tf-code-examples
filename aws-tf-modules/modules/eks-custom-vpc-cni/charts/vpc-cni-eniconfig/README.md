## vpc-cni-config Helm Chart

#### This chart will allow configuration of the VPC-CNI after EKS cluster deployment

We do not currently manage the aws-node environment variables, for helm3 to do this it would need to take control of the VPC-CNI helm chart as per this [documentation](https://artifacthub.io/packages/helm/aws/aws-vpc-cni#adopting-the-existing-aws-node-resources-in-an-eks-cluster) as this might hamper automatic VPC-CNI upgrades in the future.

Configuration of the aws-node environment variables is managed in terraform via *null_resource* for now.
