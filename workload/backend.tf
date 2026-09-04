terraform {
  backend "s3" {
    bucket = "terraform-prod-state-832191487513"

    key = "prod/sample/terraform.tfstate"

    region = "ap-south-1"

    encrypt = true

    kms_key_id = "arn:aws:kms:ap-south-1:832191487513:key/c6f1ff28-6255-4582-9d4f-e3702b94117f"

    use_lockfile = true
  }
}
