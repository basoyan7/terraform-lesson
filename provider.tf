terraform {
  backend "s3" {
    bucket = "terraform-babken-asoyan-state-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
  required_version = "1.9.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.72"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}