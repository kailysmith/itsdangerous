output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app.name
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.address
  sensitive   = true
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.identifier
}

output "s3_bucket_name" {
  description = "Name of the S3 artifact bucket"
  value       = aws_s3_bucket.artifacts.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 artifact bucket"
  value       = aws_s3_bucket.artifacts.arn
}

output "kms_key_arn" {
  description = "ARN of the customer-managed KMS key"
  value       = aws_kms_key.cmk.arn
}

output "kms_key_alias" {
  description = "Alias of the customer-managed KMS key"
  value       = aws_kms_alias.cmk.name
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "db_password_secret_arn" {
  description = "ARN of the Secrets Manager secret for the DB password"
  value       = aws_secretsmanager_secret.db_password.arn
  sensitive   = true
}

output "secret_key_secret_arn" {
  description = "ARN of the Secrets Manager secret for the application secret key"
  value       = aws_secretsmanager_secret.secret_key.arn
  sensitive   = true
}

output "sns_alerts_topic_arn" {
  description = "ARN of the SNS alerts topic"
  value       = aws_sns_topic.alerts.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task IAM role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_execution.arn
}
