# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
variable "env" {
  description = "Depolyment environment"
  default     = "<your own variable value>"
}
variable "project_name" {
  description = "Project name"
  default     = "<your own variable value>"
}

variable "AWS_ID" {
  description = "AWS ID"
  default     = "<your own variable value>"
}
variable "project_id" {
  description = "Project ID"
  default     = "<your own variable value>"
}
variable "region" {
  description = "AWS region"
  default     = "<your own variable value>"
}

variable "repository_branch" {
  description = "Repository branch to connect to"
  default     = "master"
}

variable "repository_owner" {
  description = "Gitlab repository owner"
  default     = "<your own variable value>"
}

variable "build_repository_name" {
  description = "Gitlab repository name"
  default     = "<your own variable value>"
}

variable "deploy_repository_name" {
  description = "Gitlab repository name"
  default     = "<your own variable value>"
}

variable "artifact_bucket" {
  description = "S3 Bucket for storing artifacts"
  default     = "<your own variable value>"
}

variable "GitLabServer" {
  description = "The path to the GitLab Server, e.g. https://gitlab.com, https://test.gitlab.com, http://10.0.0.1"
  default     = "https://gitlab.com"
}

variable "RepositoryBaseUrl" {
  description = "The base path to the GitLab account to create the repository within. e.g. https://gitlab.com/<username>"
  default     = "https://gitlab.com/<username>"
}

variable "SecretName" {
  description = "Token for GitLab"
  default     = "gitlab_token"
}

variable "GitLabGroupID" {
  description = "The ID of the group in GitLab to create the repositories in. Enter \"None\" if using the root group."
  default     = "None"
}

