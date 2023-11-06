# Storage Class
This module creates an encrypted Storage Class in the cluster and sets it to default.

It also sets the default EKS un-encrypted Storage Class to not default.

The volume has a 'delete' reclaim policy.

## EKS Specific
If we want to make this component more cloud agnostic we can do one of the following:
* Ensure kubeconfig and context are set as a pre-requisite or in a none aws-specific way.
* Move the logic to patch the default SC in AWS to the EKS module as it is specific to AWS. And then correspondingly move the test cases related to the eks test suite.

## Docs
* SC: https://kubernetes.io/docs/concepts/storage/storage-classes/
* Change the default SC: https://kubernetes.io/docs/tasks/administer-cluster/change-default-storage-class/
