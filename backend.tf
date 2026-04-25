terraform {
  backend "s3" {
    bucket         = "much-to-do-tfstate-techypoetic"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "much-to-do-tf-locks"
    encrypt        = true
  }
}

