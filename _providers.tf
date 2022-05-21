provider "aws" {
  region = var.aws_region
  profile = var.profile
} 

terraform {
  backend "s3" {
  }
} 