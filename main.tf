data "aws_region" "current" {}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}


resource "aws_lambda_function" "hello_world" {
  filename         = "lambda_function.zip"  # Path to your zipped Lambda code
  function_name    = "hello_world_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"  # Specify the Python version
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      key = "value"
    }
  }
}


# API Gateway (optional to expose Lambda via HTTP)
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "hello-world-api"
  description = "Hello World API"
}

resource "aws_api_gateway_resource" "my_api" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.my_api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.my_api.id
  http_method = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                  = "AWS_PROXY"
  uri                   = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.hello_world.arn}/invocations"
}

# Lambda API Gateway Permissions
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "my_api" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.my_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "my_api" {
  deployment_id = aws_api_gateway_deployment.my_api.id
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  stage_name    = "dev"
}


# Output API Gateway URL
output "api_url" {
  value = "https://${aws_api_gateway_rest_api.my_api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/dev/hello"
}