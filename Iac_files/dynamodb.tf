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
