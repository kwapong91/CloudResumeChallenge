# Lambda function configuration
resource "aws_lambda_function" "lambda" {
  filename         = "lambda_function_payload.zip"
  function_name    = "cloudresume-api-dynamodb"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"  # The handler should be "file_name.function_name"

  source_code_hash = filebase64sha256("lambda_function_payload.zip")  # Changed to correctly reference the .zip file hash

  runtime = "python3.12"
}
