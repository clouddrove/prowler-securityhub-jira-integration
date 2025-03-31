output "lambda_arn" {
  value       = module.lambda_securityhub_jira.arn
  description = "ARN of the deployed Lambda function"
}

output "event_rule_arn" {
  value       = module.cloudwatch_event_rule.arn[0]
  description = "ARN of the CloudWatch event rule"
}

output "iam_role_arn" {
  value       = module.iam_role.arn
  description = "ARN of the IAM Role for Lambda"
}