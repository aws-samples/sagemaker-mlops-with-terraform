resource "aws_sagemaker_endpoint" "sm_endpoint" {
  name                 = "${var.env}-endpoint-0408"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.endpoint_config.name
 
  tags = {
    Name = "${var.env} SageMaker Endpoint"
  }
}
 
resource "aws_sagemaker_endpoint_configuration" "endpoint_config" {
  name = "${var.env}-endpoint-config"
 
  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.approved_model.name
    initial_instance_count = 1
    instance_type          = "ml.m4.xlarge"
  }
  data_capture_config {
      enable_capture              = "true"
      initial_sampling_percentage = "100"
      destination_s3_uri          = "s3://${var.bucket}/endpoint-caputure"
      capture_options  {
        capture_mode = "Input"
        }
      capture_options  {
        capture_mode = "Output"
        }
      capture_content_type_header {
        csv_content_types        = ["text/csv"]
        json_content_types       = ["application/json"]
      }
  }
  tags = {
    Name = "${var.env} SageMaker Endpoint Config"
  }
}
 
resource "aws_sagemaker_model" "approved_model" {
  name               = "${var.env}-approved-model-0408"
  execution_role_arn = aws_iam_role.sagemaker_role.arn
 
  primary_container {
    image = var.model_image
    model_data_url = var.model_data_url
  }
}
 
