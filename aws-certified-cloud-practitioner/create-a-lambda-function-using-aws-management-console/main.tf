terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }
    archive = {
      source = "hashicorp/archive"
      version = "2.4.2"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

data "aws_iam_policy_document" "lambda-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "lambda-role" {
  assume_role_policy = data.aws_iam_policy_document.lambda-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "lambda-role-basic-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda-role.id
}

data "archive_file" "function-zip" {
  output_path = "${path.module}/function.zip"
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
}

resource "aws_lambda_function" "lambda" {
  function_name = "TerraFunction"
  role          = aws_iam_role.lambda-role.arn
  handler = "lambda_function.lambda_handler"
  filename = data.archive_file.function-zip.output_path
  runtime = "python3.12"
}

resource "aws_cloudwatch_log_group" "lambda-logs" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 7
}