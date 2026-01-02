terraform {
  backend "s3" {
    bucket         = "oggy-backend-bucket"
    key            = "Alb-project-non-module/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "stateLock-table"
  }
}