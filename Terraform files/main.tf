# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
provider "aws" {
  region  = var.region
  profile = "default"
}

provider "gitlab" {
token = var.gitlab_token
}

terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}