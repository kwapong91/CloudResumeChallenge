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

# S3 object configuration
resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.resume_website_ik.bucket
  key    = "website"
  source = "website/"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "resume_website_ik" {
  bucket = aws_s3_bucket.resume_website_ik.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 ACL configuration
resource "aws_s3_bucket_acl" "resume_website_ik_acl" {
  bucket = aws_s3_bucket.resume_website_ik.id
  acl    = "private"
}

# CloudFront distribution configuration
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.resume_website_ik.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "S3Origin"  # Local variable 'local.s3_origin_id' was missing, replaced with a string
  }

  default_root_object = "index.html"
}

# Route 53 configuration
resource "aws_route53_zone" "kwapongresume_com" {
  name = "kwapongresume.com"
}

# NS Record
resource "aws_route53_record" "kwapongresume_ns" {
  zone_id = aws_route53_zone.kwapongresume_com.zone_id
  name    = "kwapongresume.com"
  type    = "NS"
  ttl     = 300
  records = [
    "ns-905.awsdns-49.net.",
    "ns-1058.awsdns-04.org.",
    "ns-1962.awsdns-53.co.uk.",
    "ns-44.awsdns-05.com."
  ]
}

# SOA Record
resource "aws_route53_record" "kwapongresume_soa" {
  zone_id = aws_route53_zone.kwapongresume_com.zone_id
  name    = "kwapongresume.com"
  type    = "SOA"
  ttl     = 300
  records = [
    "ns-905.awsdns-49.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  ]
}

# CNAME Record
resource "aws_route53_record" "kwapongresume_cname" {
  zone_id = aws_route53_zone.kwapongresume_com.zone_id
  name    = "_719b7cc3bd90107b459648a65b97b538.kwapongresume.com"
  type    = "CNAME"
  ttl     = 300
  records = [
    "_e550865965f4a7caa472307b268152d7.djqtsrsxkq.acm-validations.aws"
  ]
}

# A Record
resource "aws_route53_record" "kwapongresume_a" {
  zone_id = aws_route53_zone.kwapongresume_com.zone_id
  name    = "resume.kwapongresume.com"
  type    = "A"
  alias {
    name                   = "d1p6wbkby62tvx.cloudfront.net"
    zone_id                = "E3H8D5SMWILLF0"
    evaluate_target_health = true
  }
}

# DynamoDB table configuration
resource "aws_dynamodb_table" "cloudresume_dynamodb" {
  name           = "cloudtest"
  billing_mode   = "PROVISIONED"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "views"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "project"
    Environment = "Cloud Resume Challenge"
  }
}

# Lambda function IAM policy for accessing DynamoDB
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem"
    ]
    resources = ["arn:aws:dynamodb:us-east-1:235494808933:table/cloudtest"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Lambda function configuration
resource "aws_lambda_function" "lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "cloudresume-api-dynamodb"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"  # The handler should be "file_name.function_name"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")  # Changed to correctly reference the .zip file hash

  runtime = "python3.12"
}
