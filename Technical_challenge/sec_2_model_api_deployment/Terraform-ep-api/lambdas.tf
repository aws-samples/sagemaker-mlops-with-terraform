# Create a lambda function
# In terraform ${path.module} is the current directory.

resource "aws_lambda_function" "endpoint_invoke_lambda" {
  filename =local.filename
  function_name    = "dlt-${local.env}-invoke-endpoint"
  role             = "${aws_iam_role.lambda_exec.arn}"
  handler          = "invoke_lambda.lambda_handler"
  runtime          = "python3.7"
  timeout          = 180

  environment {
    variables = {
         "ENDPOINT_NAME": "${aws_sagemaker_endpoint.sm_endpoint.name}"
    }
  }
}

locals {
  region = "us-east-1"
  env="test"
  filename= "invoke_lambda.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "invoke_lambda_role_0408"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  inline_policy {
    name = "my_inline_policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:*:*:*"
        },
        {
            "Action": [
                "sagemaker:InvokeEndpoint"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
      ]
    })
  }

}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "predict"
  rest_api_id = "${aws_api_gateway_rest_api.sagemakerapi.id}"
  parent_id   = "${aws_api_gateway_rest_api.sagemakerapi.root_resource_id}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${aws_api_gateway_rest_api.sagemakerapi.id}"
  resource_id   = "${aws_api_gateway_resource.resource.id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.sagemakerapi.id}"
  resource_id = "${aws_api_gateway_method.method.resource_id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "${aws_lambda_function.endpoint_invoke_lambda.invoke_arn}"
}
resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = "${aws_api_gateway_rest_api.sagemakerapi.id}"
  resource_id = "${aws_api_gateway_method.method.resource_id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = "${aws_api_gateway_rest_api.sagemakerapi.id}"
  resource_id = "${aws_api_gateway_method.method.resource_id}"
  http_method = "${aws_api_gateway_method.method.http_method}"
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_deployment" "sagemakerapi" {
  depends_on = [
    "aws_api_gateway_integration.lambda"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.sagemakerapi.id}"
  stage_name  = "test"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.endpoint_invoke_lambda.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.sagemakerapi.execution_arn}/*/*"
}