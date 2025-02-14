provider "aws" {
  region = "us-east-1"
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach policy to allow logging
resource "aws_iam_policy_attachment" "lambda_logs" {
  name       = "lambda_logs_attachment"
  roles      = [aws_iam_role.iam_for_lambda.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Archive the Lambda function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "python/index.js"
  output_path = "lambda/lambda_function_payload.zip"
}

# Lambda Function
resource "aws_lambda_function" "test_lambda" {
  filename         = "lambda/lambda_function_payload.zip"
  function_name    = "lambda_function_name"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "index.test"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "nodejs18.x"

  environment {
    variables = {
      foo = "bar"
    }
  }
}
output "hash" {
  value = aws_lambda_function.test_lambda.source_code_hash
}
output "lambda-hashcode01" {

  value = filebase64sha256("lambda/lambda_function_payload.zip")

}
output "lambda-hashcode02" {

  value = data.archive_file.lambda.output_base64sha256

}
output "lambda-hashcode03" {

  value = filebase64sha256(data.archive_file.lambda.output_path)

}