
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "env" {
  description = "environment"
  default     = "test"
}


variable "model_image" {
  description = "image"
  default     = "683313688378.dkr.ecr.us-east-1.amazonaws.com/sagemaker-xgboost:1.7-1"
}

variable "model_data_url" {
  description = "model data"
  default     = "s3://<your bucket>/<your prefix>/model.tar.gz"
}

variable "bucket" {
  description = "bucket"
  default     = "<your bucket>"
}