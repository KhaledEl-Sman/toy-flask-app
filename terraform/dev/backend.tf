terraform {
  backend "s3" {
    bucket         = "botit-terraform-state-eu"
    key            = "envs/dev/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


