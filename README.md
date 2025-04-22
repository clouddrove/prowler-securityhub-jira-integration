# prowler-securityhub-jira-integration
Automates sending Prowler findings to AWS SecurityHub and Jira for streamlined security management. 🚀

## Step By Step Setup: 

### Prerequisites:

* ***Jira API Access:*** You need a Jira account, API token, and the project key where issues will be created.

* ***Terraform:*** For automating Lambda deployment.
* Before running the Lambda function, ensure you have security hub and Prowler enable:
- AWS Security Hub: Configured and enabled in the regions you are monitoring.

### Prowler AWS Security Scanning Workflow:
Follow below steps to configure prowler and send findings to AWS security-hub.
#### Features

- 🔒 **Single and Multi-account scanning** using a single workflow run
- 🔄 **OIDC authentication** for secure, short-lived access
- 🚨 **Findings sent to AWS Security Hub**
- ☁️ Optional **S3 upload** for report retention
- 💬 Optional **Slack notifications** for scan results
- 📦 **Reusable workflow** for easy integration and maintenance

---

#### Setup

##### 1. Prerequisites

- AWS accounts with an IAM role for Prowler scanning (`PROWLER_ROLE_NAME`) with below policy.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ProwlerReadOnlyAccess",
            "Effect": "Allow",
            "Action": [
                "access-analyzer:List*",
                "apigateway:GET",
                "cloudformation:Describe*",
                "cloudfront:Get*",
                "cloudtrail:Describe*",
                "cloudtrail:Get*",
                "cloudwatch:Describe*",
                "cloudwatch:Get*",
                "config:Describe*",
                "config:Get*",
                "ec2:Describe*",
                "eks:Describe*",
                "elasticache:Describe*",
                "elasticloadbalancing:Describe*",
                "guardduty:Get*",
                "iam:GenerateCredentialReport",
                "iam:Get*",
                "iam:List*",
                "inspector2:List*",
                "kms:List*",
                "rds:Describe*",
                "redshift:Describe*",
                "s3:GetBucketLocation",
                "s3:GetBucketPolicyStatus",
                "s3:GetBucketPublicAccessBlock",
                "s3:ListAllMyBuckets",
                "secretsmanager:ListSecrets",
                "securityhub:BatchImportFindings",
                "securityhub:Get*",
                "ssm:Describe*",
                "sts:GetCallerIdentity"
            ],
            "Resource": "*"
        }
    ]
}
```
- A central AWS account with an OIDC role for GitHub Actions (`BUILD_ROLE`)
- GitHub repository with access to store secrets.

##### 2. Configure Secrets

Go to your repository (or organization) **Settings → Secrets and variables → Actions** and add the following secrets:

| Secret Name           | Description                                   |
|-----------------------|-----------------------------------------------|
| `BUILD_ROLE`          | OIDC role ARN in your central AWS account     |
| `PROWLER_ROLE_NAME`   | Name of the IAM role to assume in each target |
| `AWS_ACCESS_KEY_ID`   | (Optional) AWS access key for fallback        |
| `AWS_SECRET_ACCESS_KEY` | (Optional) AWS secret key for fallback      |
| `AWS_SESSION_TOKEN`   | (Optional) AWS session token for fallback     |
| `TARGET_ACCOUNT_ID`   | Space-separated list of AWS account IDs       |
| `S3_BUCKET_NAME`      | (Optional) S3 bucket for report uploads       |
| `SLACK_WEBHOOK`       | (Optional) Slack webhook URL                  |
| `SLACK_USERNAME`      | (Optional) Slack username                     |
- ***Note:*** Add secrets as per need.

##### 3. Configure the Workflow

Create a workflow file (e.g., `.github/workflows/prowler.yml`)
For reference, see [example_prowler_workflow ](./.github/workflows/prowler.yaml) in this repository.


### Terraform Code Deployment: 

- checkout to the terraform directory:

```bash
 cd terraform
```
- Add variables in Variables.tf file or create .tfvars file.

- Initialize Terraform:

```hcl
terraform init
```

- Plan the Deployment:

``` hcl
terraform plan
```

- Apply the Configuration:

```hcl
terraform apply
```
### Testing and Validation:
- First test , if all aws resources created successfully and configured. For that we can check for following:

    - Iam role, policies and Trust Relationship policy attached properly.

    ![Alt text](images/pro-5.png)

    - Check for lambda function created properly.

    ![Alt text](images/pro-6.png)

    - Check for lambda function code and all other dependencies files.

    ![Alt text](images/pro-7.png)

    - In lambda function , check configurations for permissions, if correct role is attached or not.

    ![Alt text](images/pro-8.png)

    - check for environment variables in lambda function (can also update manually for filters).

    ![Alt text](images/pro-9.png)

    - check for Event Bridge trigger in lambda function configurations.

    ![Alt text](images/pro-11.png)

    - Trigger a Security Hub Finding: Create a finding matching the filter criteria and verify that the Lambda function creates a Jira ticket.

- ***Check CloudWatch Logs:*** Validate Lambda execution logs in CloudWatch.

- ***Jira Verification:*** Confirm that issues are created in the specified Jira project with correct details.

- ***NOTE:***  Trigger lambda code manually first time after deploy for sending old findings to jira, then for every new findings it will trigger automatically.

    - for trigger lambda function create an empty test event and invoke .

    ![Alt text](images/pro-13.png)

    - then check on Jira for new issues as per the filter in the all issues section from left panel.

    ![Alt text](images/pro-14.png)

    - Jira issue will look like that.

    ![Alt text](images/pro-17.png)
    ![Alt text](images/pro-16.png)
 

Now, with this seamless setup, Jira tickets will automatically appear in the Jira console under the designated epic—ensuring effortless tracking, better collaboration, and a streamlined workflow! 🚀
