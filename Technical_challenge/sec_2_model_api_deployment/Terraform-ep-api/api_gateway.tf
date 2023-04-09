resource "aws_api_gateway_rest_api" "sagemakerapi" {
  name        = "invoke-sagemaker-API"
  description = "Rest API gateway for SageMaker endpoint"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.sagemakerapi.invoke_url}"
}