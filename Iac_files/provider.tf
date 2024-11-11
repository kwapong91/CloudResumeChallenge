terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.74.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# S3 bucket configuration
resource "aws_s3_bucket" "resume_website_ik" {
  bucket = "resume-website-ik"

  tags = {
    "Name" = "Cloud Resume Challenge"
  }
}