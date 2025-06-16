# zipping the python file to create a lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file  = "${path.module}/python/toggle.py"
  output_path = "${path.module}/python/toggle.zip"
  
}


# creating lambda role 
resource "aws_iam_role" "lamda-role" {
  name = "schedule-lambda"
  assume_role_policy =<<EOF
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
    }
    EOF


}

# Creating Lambda policy to allow Lambda to execute and manage EC2 instances
resource "aws_iam_policy" "lambda_exec_policy" {
  name        = "lambda_exec_policy"
  description = "Permissions for Lambda to log and manage EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attaching the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "attachment" {

    policy_arn = aws_iam_policy.lambda_exec_policy.arn
    role = aws_iam_role.lamda-role.name
  
}

# creating lambda function
resource "aws_lambda_function" "toggle_lambda" {
    function_name = "toggle_ec2_instance"
    role =aws_iam_role.lamda-role.arn
    handler = "toggle.lambda_handler"
    runtime = "python3.10"
    timeout = 5
    filename = data.archive_file.lambda_zip.output_path
    depends_on = [ aws_iam_role_policy_attachment.attachment, 
                   aws_iam_role.lamda-role,aws_iam_policy.lambda_exec_policy
    ]
  
}


# creating a cloudwatch event rule to trigger the lambda function every 1 minute
resource "aws_cloudwatch_event_rule" "every_minute" {
  name        = "every_minute"
  description = "Trigger Lambda every 5 minutes"
  schedule_expression = "rate(1 minute)"
}


# creating lambda permission to allow cloudwatch to invoke the lambda function
# its resource policy
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.toggle_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_minute.arn
}


# creating a cloudwatch event target to link the rule to the lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_minute.name
  target_id = "toggle_ec2_instance"
  arn       = aws_lambda_function.toggle_lambda.arn
}