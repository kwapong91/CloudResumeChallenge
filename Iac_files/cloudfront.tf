# CloudFront distribution configuration
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.resume_website_ik.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
    origin_id                = "S3Origin"  # Local variable 'local.s3_origin_id' was missing, replaced with a string
  }

  default_root_object = "index.html"
}
