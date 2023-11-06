from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.terraform.checks.resource.base_resource_check import BaseResourceCheck


class EKSAMI(BaseResourceCheck):
    def __init__(self):
        name = "Ensure all worker node managed groups are using a custom AMI"
        id = "CKV_EKS_AMI"
        supported_resources = ['aws_launch_template']
        categories = [CheckCategories.ENCRYPTION]
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def scan_resource_conf(self, conf):
        """
            Looks for values for AMI IDs used by EKS worker node group:
            https://www.terraform.io/docs/providers/aws/r/launch_template.html
        :param conf: aws_eks_node_group configuration
        :return: <CheckResult>
        """
        if 'image_id' in conf.keys():
            if conf['image_id'][0] != '':
                return CheckResult.PASSED
        return CheckResult.FAILED


check = EKSAMI()
