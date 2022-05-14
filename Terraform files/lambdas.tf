# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0

resource "aws_lambda_function" "seedcode_checkin_lambda" {
  s3_bucket = "${var.artifact_bucket}"
  s3_key    = "gitlab-project/lambda-seedcode-checkin-gitlab.zip"
  function_name    = "sagemaker-${var.project_id}-git-seedcodecheckin"
  role             = aws_iam_role.gitlab_mlops_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 180

  environment {
    variables = {
         "GitLabServer": "${var.GitLabServer}",
         "DeployProjectName": "${var.deploy_repository_name}",
         "BuildProjectName": "${var.build_repository_name}",
         "SageMakerProjectName": "${var.project_name}",
         "SageMakerProjectId": "${var.project_id}",
         "SecretName": "${var.SecretName}",
         "SeedCodeBucket": "${var.artifact_bucket}",
         "ModelBuildSeedCode": "gitlab-project/mlops-gitlab-project-seedcode-model-build.zip",
         "ModelDeploySeedCode": "gitlab-project/mlops-gitlab-project-seedcode-model-deploy.zip",
         "Region": "${var.region}",
         "AccountId": "${var.AWS_ID}",
         "Role": aws_iam_role.gitlab_mlops_role.arn,
         "GroupId": "${var.GitLabGroupID}"
    }
  }
}

resource "aws_lambda_function" "gitlab_pipeline_trigger_lambda" {
  s3_bucket = "${var.artifact_bucket}"
  s3_key    = "gitlab-project/lambda-gitlab-pipeline-trigger.zip"
  function_name    = "sagemaker-${var.project_id}-gitlab-trigger"
  role             = aws_iam_role.gitlab_mlops_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 900

  environment {
    variables = {
         "GitLabServer": "${var.GitLabServer}",
         "DeployProjectName": "${var.deploy_repository_name}",
         "BuildProjectName": "${var.build_repository_name}",
         "SageMakerProjectName": "${var.project_name}",
         "SageMakerProjectId": "${var.project_id}",
         "SecretName": "${var.SecretName}",
         "Region": "${var.region}",
         "GroupId": "${var.GitLabGroupID}"
    }
  }
}

data "aws_lambda_invocation" "SeedCodeCheckinLambdaInvoker" {
  depends_on    = [aws_lambda_function.seedcode_checkin_lambda]
  function_name = aws_lambda_function.seedcode_checkin_lambda.function_name

  input = <<JSON
   {    
        "GitLabServer": "${var.GitLabServer}",
         "DeployProjectName": "${var.deploy_repository_name}",
         "BuildProjectName": "${var.build_repository_name}",
         "SageMakerProjectName": "${var.project_name}",
         "SageMakerProjectId": "${var.project_id}",
         "SecretName": "${var.SecretName}",
         "SeedCodeBucket": "${var.artifact_bucket}",
         "ModelBuildSeedCode": "gitlab-project/mlops-gitlab-project-seedcode-model-build.zip",
         "ModelDeploySeedCode": "gitlab-project/mlops-gitlab-project-seedcode-model-deploy.zip",
         "Region": "${var.region}",
         "AccountId": "${var.AWS_ID}",
         "Role": "aws_iam_role.gitlab_mlops_role.arn",
         "GroupId": "${var.GitLabGroupID}"
    }
JSON
}


resource "aws_sagemaker_code_repository" "ModelBuildSagemakerCodeRepository" {
  code_repository_name = "${var.build_repository_name}-${var.project_id}"

  git_config {
    branch = "main"
    repository_url = "${var.RepositoryBaseUrl}/${var.build_repository_name}-${var.project_id}"
  }
  depends_on = [data.aws_lambda_invocation.SeedCodeCheckinLambdaInvoker]
}

resource "aws_sagemaker_code_repository" "ModelDeploySagemakerCodeRepository" {
  code_repository_name = "${var.deploy_repository_name}-${var.project_id}"

  git_config {
    branch = "main"
    repository_url = "${var.RepositoryBaseUrl}/${var.deploy_repository_name}-${var.project_id}"
  }
  depends_on = [data.aws_lambda_invocation.SeedCodeCheckinLambdaInvoker]
}