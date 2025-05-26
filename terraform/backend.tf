terraform {
  backend "s3" {
    bucket         = "${var.project_name_prefix}-terraform-state"
    key            = "envs/prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
