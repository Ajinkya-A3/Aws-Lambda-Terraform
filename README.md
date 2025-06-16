
# 🛠️ Terraform Module: Lambda Automation with CloudWatch Scheduler

This module provisions an AWS Lambda function that can be triggered by a CloudWatch Event Rule on a schedule.
It includes all necessary IAM roles, policies, and permissions. You can reuse it to deploy **any Python-based Lambda**
and associate it with a CloudWatch scheduler.

---

## 📁 Project Structure

```
.
├── main.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
├── policies/
│   └── lambda_policy.json
├── python/
│   └── toggle.py
```

---

## ⚙️ Features

- Zip and deploy a Python Lambda function
- IAM role and policy attachment for execution
- CloudWatch Event Rule to trigger Lambda on schedule
- Parameterized using Terraform variables for reusability
- Uses `templatefile` to inject dynamic IAM permissions

---

## 🔧 Required Variables

In your `terraform.tfvars`, you should define:

```hcl
lambda_function_name        = "toggle_ec2_instance"              # Lambda function name
lambda_handler_name         = "toggle.lambda_handler"            # Python handler (filename.function)
lambda_runtime              = "python3.10"                       # Lambda runtime
lambda_timeout              = 5                                  # Timeout in seconds

lambda_source_file          = "python/toggle.py"                 # Path to Python source file
lambda_zip_output_file      = "python/toggle.zip"                # Output zip path

policy_template_path        = "policies/lambda_policy.json"      # IAM policy template path

cloudwatch_rule_name        = "every_minute"                     # CloudWatch rule name
cloudwatch_schedule         = "rate(1 minute)"                   # Schedule expression
cloudwatch_rule_description = "Trigger Lambda every 1 minute"    # Rule description
```

---

## 🔐 IAM Policy Template

Example `policies/lambda_policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
    // You can add more permissions here as needed
  ]
}
```

---

## 📜 Lambda Code

Place your Python logic inside `python/<file_name>.py`. This file will be zipped automatically during Terraform run.

**Test Lambda**

Use the AWS Console or AWS CLI to invoke the Lambda function to test:

```bash
aws lambda invoke \
  --function-name <function_name> \
  --payload '{}' \
  response.json
```

---

## ▶️ Usage

```bash
terraform init
terraform apply
```

---

## ✅ What Gets Created

- Lambda function zipped and deployed
- IAM role for Lambda execution
- IAM policy using dynamic template
- CloudWatch Event Rule on defined schedule
- Lambda permission for CloudWatch to invoke
- Event Target linking CloudWatch to Lambda

---

## 📌 Notes

- Keep the policy template JSON compliant with IAM standards.
- Schedule expression must follow AWS `rate()` or `cron()` format.
- Lambda files are zipped at runtime using the `archive_file` data source.

---

## 💥 Clean Up

To remove all resources:

```bash
terraform destroy
```

---

## 📄 License

Licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
