provider "aws" {
  region  = "us-east-1"
  profile = "iesawsna-sandbox"
}

terraform {
  backend "s3" {
  }
}
