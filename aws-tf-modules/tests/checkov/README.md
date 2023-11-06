# TERRAFORM UNIT TESTS #

These are all the UNIT tests executing pre-terraform plan phase to ensure the components PASS the basic module comformity, during AWS resource provisioning.

These are based on Checkov Test framework https://github.com/bridgecrewio/checkov

## HOW-TO Guide

Enter the terraform directory, and perform 

```
terraform init
```

Execute the checkov test suite which runs generic unit tests by default. Specify custom unit test directory to be run as well

```
checkov -d .terraform/modules/eks/ --external-checks-dir=/tests/checkov
```

# Tests included
Decision log and description of test suite.

## Custom Tests

These tests are written in-house

**Id	Type	    Entity	    Policy	                                                                                IaC**

0  **CKV_EKS_AMI**   resource  Ensure all worker node managed groups are using a custom AMI                         Terraform
