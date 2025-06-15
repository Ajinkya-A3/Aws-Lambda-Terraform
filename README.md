
# 🔁 AWS Lambda EC2 Toggle with Terraform

This project creates an AWS Lambda function using **Terraform** that **automatically toggles EC2 instances (start/stop)** based on their current state and a specific tag (e.g., `Environment=Dev`).

The Lambda function:
- Finds EC2 instances tagged with a specific key/value (e.g., `Environment=Dev`)
- Starts stopped instances
- Stops running instances
- Uses IAM roles and policies to securely access EC2 and CloudWatch Logs
- Is deployed and zipped automatically using Terraform

---

## 🧱 Project Structure

```
.
├── main.tf                  # Terraform configuration
├── python/
│   ├── toggle.py            # Lambda function code
```

---

## 🛠️ Prerequisites

- Terraform installed (`v1.10.0+`)
- AWS CLI configured (`aws configure`)
- Python (only for Lambda development)
- IAM credentials with permission to deploy Lambda, IAM roles, and EC2

---

## 🔧 What This Project Does

- 📦 Zips `toggle.py` using Terraform `archive_file`
- 🔐 Creates an IAM role and policy for Lambda:
  - Logs to CloudWatch
  - Describes, starts, and stops EC2 instances
- 🚀 Deploys a Lambda function written in Python 3.10
- ⏱️ Sets a 5-second timeout for the function

---

## 🚀 How to Deploy

1. **Clone the Repository**

```bash
git clone <repo-url>
cd Aws-Lambda-Terraform

```

2. **Initialize Terraform**

```bash
terraform init
```

3. **Review Plan**

```bash
terraform plan
```

4. **Apply Changes**

```bash
terraform apply
```

5. **Test Lambda**

Use the AWS Console or AWS CLI to invoke the Lambda function:

```bash
aws lambda invoke \
  --function-name toggle_ec2_instance \
  --payload '{}' \
  response.json
```

---

## 📜 Lambda Function Logic

Located in `python/toggle.py`, the function:

- Uses `boto3` to connect to EC2
- Filters instances by tag: `Environment=Dev`
- Stops instances that are running
- Starts instances that are stopped
- Logs all actions using the `logging` module

---

## 🧠 Customization

You can change the following inside `toggle.py`:

```python
TAG_KEY = 'Environment'
TAG_VALUE = 'Dev'
```

To target different instance groups by tag.

---

## 🔐 IAM Permissions Used

The Lambda execution policy allows:

```json
{
  "ec2:DescribeInstances",
  "ec2:StartInstances",
  "ec2:StopInstances",
  "logs:*"
}
```

These permissions can be scoped further using specific `Resource` ARNs for tighter security.

---

## 📎 Useful Tips

- Lambda timeout is currently set to **5 seconds**, adjust it in `main.tf` if needed.
- This function can be scheduled using **EventBridge (CloudWatch Scheduled Event)** if desired.
- If managing large fleets, consider increasing timeout and batching logic.

---

## 🧼 Clean Up

To remove all resources:

```bash
terraform destroy
```

---

## 📄 License

This project is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
