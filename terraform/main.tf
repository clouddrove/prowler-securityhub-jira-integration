provider "aws" {
  region = var.aws_region
}

module "iam_role" {
  source               = "clouddrove/iam-role/aws"
  version = "1.3.2"
  name                 = var.iam_role_name
  label_order          = var.label_order
  enabled              = true
  assume_role_policy   = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  path                 = "/"
  policy_enabled       = true
  description          = var.iam_role_description
  max_session_duration = var.iam_role_max_session_duration
  policy_arn           = ""

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["securityhub:GetFindings", "securityhub:DescribeHub"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })

  managed_policy_arns = var.managed_policy_arns
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install --target ${path.module}/lambda_src boto3 requests"
  }
}

data "archive_file" "lambda_package" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda_function.zip"
  depends_on  = [null_resource.install_dependencies]
}

module "lambda_securityhub_jira" {
  source                        = "clouddrove/lambda/aws"
  version = "1.3.1"
  name                          = var.lambda_name
  label_order                   = var.label_order
  handler                       = var.lambda_handler
  filename                      = data.archive_file.lambda_package.output_path
  iam_role_arn                  = module.iam_role.arn
  runtime                       = var.lambda_runtime
  timeout                       = var.lambda_timeout
  create_iam_role               = false
  enable_kms                    = false
  existing_cloudwatch_log_group = false
  attach_cloudwatch_logs_policy = false
  memory_size                   = var.lambda_memory_size
  reserved_concurrent_executions = null

  variables = {
    JIRA_URL         = var.jira_url
    JIRA_EMAIL       = var.jira_email
    JIRA_API_TOKEN   = var.jira_api_token
    JIRA_PROJECT_KEY = var.jira_project_key
    FILTER_PRODUCT   = var.filter_product
    FILTER_SEVERITY  = var.filter_severity
    FILTER_ACCOUNT   = var.filter_account
    FILTER_REGION    = var.filter_region
    JIRA_EPIC_ID     = var.jira_epic_id
}
}

module "cloudwatch_event_rule" {
  source        = "clouddrove/cloudwatch-event-rule/aws"
  version = "1.0.1"
  enabled       = true
  name          = var.event_rule_name
  label_order   = var;label_order
  description   = var.event_rule_description
  event_pattern = var.event_rule_pattern
  target_id     = var.event_rule_target_id
  arn           = module.lambda_securityhub_jira.arn
  input_paths   = {}
  input_template = "{}"
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_securityhub_jira.name
  principal     = "events.amazonaws.com"
  source_arn    = module.cloudwatch_event_rule.arn[0]
}