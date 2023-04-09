
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "dbuser" {
  description = "user"
  default     = "<user>"
}

variable "dbpassword" {
  description = "password"
  default     = "<your super password>"
}

variable "identifier" {
  description = "identifier"
  default     = "testdb-us-east-1-544507241185"
}