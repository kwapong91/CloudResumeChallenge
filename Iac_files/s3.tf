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