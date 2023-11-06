# EKS Worker Groups

# User Data

The Launch Configurations of the Autoscaling Group contain the user data definition used for bootstrapping EKS workers.

The User Data defines the following:

### Certificate: nbs-management-networking. 

Stored in `/etc/pki/ca-trust/source/anchors/root_ca.pem`

Valid From: August 5, 2019
Valid To: August 5, 2029

Uses: This is the root CA used to create the certificate used by artifactory. It enables docker to download containers from artifactory. 

### Certificate: Nationwide Root CA2

Stored in `/etc/pki/ca-trust/source/anchors/NationwideRootCA2.pem`

Valid From: March 25, 2015
Valid To: March 25, 2035

Uses: Unknown (TODO)

### Bootstrap Kubelet Config

The script `/etc/eks/bootstrap.sh` will be executed during startup. This script replaces the contents of `/var/lib/kubelet/kubeconfig` with configuration directing the worker
to make contact with the EKS cluster.

Example:
```
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca.crt
    server: https://C848CEA165B5E10206B7BE.gr7.eu-west-2.eks.amazonaws.com
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: kubelet
  name: kubelet
current-context: kubelet
users:
- name: kubelet
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: /usr/bin/aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "CLUSTER_NAME"
        - --region
        - "eu-west-2"
```

Source: https://github.com/awslabs/amazon-eks-ami/blob/master/files/bootstrap.sh

# Debugging startup errors on Amazon AMIs

Start by checking for cloud-init issues and ensure the userdata has fully executed. Ensure the kubelet has been configured with the correct cluster id and certificates. The workers connect to the cluster and register themselves via the kubelet so check the logs for startup issues.

## SSH Access to worker nodes

When EKS work groups are created you have the option to either provide your own SSH public key or have terraform
generate a new one. If a key is generated the public and private key will be placed in AWS Secrets Manager. You can download
then use the private key (in pem format) to access a node.

* Obtain the private key from AWS Secret Manager: 
 
```
aws secretsmanager get-secret-value --secret-id dev-1-eks-workers-key-pair-private | jq -r '.SecretString' > ~/.ssh/id_rsa
```

Note: The exact name will be different depending on your environment.

```
ssh ec2-user@IP_ADDRESS -i ~/.ssh/id_rsa
```

Where IP_ADDRESS is the IP address of your worker nodes.

It is likely that you will need to enable VPN access to the worker. VPN CIDRs can be enabled as part of cluster creation or managed via the AWS console.

## Check cloud init log

/var/lib/cloud/instance/scripts/part-001

## Check kubelet journal

The bootstrap.sh script mentioned above will have registered the kubelet service with systemd if not already
present. You are able to view logs of the service using.

sudo journalctl -u kubelet.service

Stop or start the service as required

systemctl restart kubelet.service

## CNI Log collector

The CNI log collector can be used to help debug CNI related errors. The script collects logs
from several sources and bundles them into tar.gz for easy transfer. Use something like SCP to grab
the logs from the worker instance and inspect locally.

sudo bash /opt/cni/bin/aws-cni-support.sh

# References

* Amazon EKS AMI: https://github.com/awslabs/amazon-eks-ami/tree/master
* EKS Troubleshooting: https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html
* EC2 User Data Guide: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html