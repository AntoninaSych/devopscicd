terraform {
  backend "s3" {
    bucket         = "lesson-7-terraform-state"
    key            = "lesson-7/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "lesson-7-terraform-locks"
    encrypt        = true
  }
}
