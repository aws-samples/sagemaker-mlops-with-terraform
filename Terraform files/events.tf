#Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_cloudwatch_event_rule" "sm_model_registry_rule" {
  name        = "sagemaker-registry-event-rule"
  description = "Capture new model registry"

  event_pattern = <<EOF
{
  "source": [
     "aws.sagemaker"
 ],
 "detail-type": [
     "SageMaker Model Package State Change"
 ],
 "detail": {
     "ModelPackageGroupName": ["${var.project_name}-${var.project_id}"    
]
 }
}
EOF
}

resource "aws_cloudwatch_event_target" "sm_model_registry" {
  rule      = aws_cloudwatch_event_rule.sm_model_registry_rule.name
  target_id = "sagemaker-${var.project_name}-registry-trigger"
  arn       = aws_lambda_function.gitlab_pipeline_trigger_lambda.arn
}

resource "aws_lambda_permission" "PermissionForEventsToInvokeLambda" {
  statement_id  = "AllowExecutionFromEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gitlab_pipeline_trigger_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sm_model_registry_rule.arn
}