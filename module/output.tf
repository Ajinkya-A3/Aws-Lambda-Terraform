output "lambda_function_name" {
  description = "The name of the deployed Lambda function"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_role_arn" {
  description = "The IAM role ARN attached to the Lambda function"
  value       = aws_iam_role.lambda_role.arn
}

output "cloudwatch_event_rule_name" {
  description = "The name of the CloudWatch rule"
  value       = aws_cloudwatch_event_rule.lambda_trigger.name
}

output "cloudwatch_event_rule_arn" {
  description = "The ARN of the CloudWatch rule"
  value       = aws_cloudwatch_event_rule.lambda_trigger.arn
}
