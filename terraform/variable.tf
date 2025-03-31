variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "label_order"{
  description = "label order"
  type = list(string)
  default = ["name"]
}

variable "iam_role_name" {
  description = "IAM Role name for Lambda"
  type        = string
  default     = "jira-integration-lambda-role"
}

variable "jira_epic_id"{  
  type       = string
  default    = ""
  description = "epic id iin which you want to create jira issues"
}

variable "iam_role_description" {
  description = "IAM Role description"
  type        = string
  default     = "Jira integration Lambda function IAM role with permissions for Security Hub and CloudWatch logs"
}

variable "iam_role_max_session_duration" {
  description = "Max session duration for IAM role"
  type        = number
  default     = 3600
}

variable "managed_policy_arns" {
  description = "List of managed policy ARNs for IAM role"
  type        = list(string)
  default     = [""]
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
  default     = "lambda_function.lambda_handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime version"
  type        = string
  default     = "python3.9"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB"
  type        = number
  default     = 128
}

variable "lambda_environment_variables" {
  description = "Lambda environment variables"
  type        = map(string)
  default     = {
    ENVIRONMENT = "dev"
    DEBUG       = "true"
  }
}

variable "event_rule_name" {
  description = "CloudWatch event rule name"
  type        = string
  default     = "jira-integration-event-rule"
}

variable "event_rule_description" {
  description = "Description of CloudWatch event rule"
  type        = string
  default     = "Triggers Lambda when Security Hub detects a new finding"
}

variable "event_rule_pattern" {
  description = "Event pattern for Security Hub findings"
  type        = string
  default     = <<EOF
{
  "source": ["aws.securityhub"],
  "detail-type": ["Security Hub Findings - Imported"]
}
EOF
}

variable "event_rule_target_id" {
  description = "Target ID for CloudWatch event rule"
  type        = string
  default     = "securityhub_jira_lambda"
}

# Jira variables with default values
variable "jira_url" {
  description = "JIRA URL"
  type        = string
  default     = "https://example.atlassian.net/"
}

variable "jira_email" {
  description = "JIRA email for authentication"
  type        = string
  default     = "abc@example.com"
}

variable "jira_api_token" {
  description = "JIRA API token for authentication"
  type        = string
  default     = ""
}

variable "jira_project_key" {
  description = "JIRA project key"
  type        = string
  default     = ""
}

# Security Hub filter variables with default values
variable "filter_product" {
  description = "Filter for product in Security Hub findings"
  type        = string
  default     = "Prowler, securityhub"
}

variable "filter_severity" {
  description = "Filter for severity levels in Security Hub findings"
  type        = string
  default     = "CRITICAL, HIGH"
}

variable "filter_account" {
  description = "AWS account IDs to filter findings"
  type        = string
  default     = "0540xxxxxxxx, 2367xxxxxxxxxxxx"
}

variable "filter_region" {
  description = "AWS regions to filter findings"
  type        = string
  default     = "us-east-1"
}
variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "jira-integration-lambda-function" 
}