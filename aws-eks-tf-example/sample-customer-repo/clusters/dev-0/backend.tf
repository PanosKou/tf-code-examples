terraform {
  required_version = ">= 0.13"

  backend "s3" {
    bucket                  = "dev-eu-west-2-terraform-remote-state-app-creator"
    key                     = "dev-0/terraform.tfstate"
    region                  = "eu-west-2"
    shared_credentials_file = ".credentials.aws"
    role_arn                = "arn:aws:iam::<ACCOUNT_ID>:role/dev-role-app-creator"
    dynamodb_table          = "dev-0"
    encrypt                 = true
  }
}
