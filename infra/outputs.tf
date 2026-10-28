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

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.app.repository_url
}

output "signing_secret_arn" {
  description = "ARN of the Secrets Manager secret for the signing key"
  value       = aws_secretsmanager_secret.signing_key.arn
  sensitive   = true
}

output "kms_secrets_key_arn" {
  description = "ARN of the KMS key used for Secrets Manager"
  value       = aws_kms_key.secrets.arn
}

output "kms_cloudwatch_key_arn" {
  description = "ARN of the KMS key used for CloudWatch Logs"
  value       = aws_kms_key.cloudwatch.arn
}

output "kms_ecr_key_arn" {
  description = "ARN of the KMS key used for ECR"
  value       = aws_kms_key.ecr.arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAFv2 Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for ECS tasks"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task IAM role"
  value       = aws_iam_role.ecs_task.arn
}
