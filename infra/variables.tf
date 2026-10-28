variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "itsdangerous"
}

variable "environment" {
  description = "Deployment environment (e.g. prod, staging)"
  type        = string
  default     = "prod"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "ID of the user-supplied VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs (for ALB and NAT Gateways)"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs (for ECS tasks)"
  type        = list(string)
}

variable "container_image" {
  description = "Full ECR image URI for the itsdangerous application container"
  type        = string
  default     = "placeholder:latest"
}

variable "container_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "ECS task CPU units (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "ECS task memory in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto-scaling"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto-scaling"
  type        = number
  default     = 10
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilisation percentage for auto-scaling"
  type        = number
  default     = 60
}

variable "alb_ssl_policy" {
  description = "SSL/TLS policy for the ALB HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the ALB HTTPS listener"
  type        = string
}

variable "health_check_path" {
  description = "Path for ALB target group health checks"
  type        = string
  default     = "/health"
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 90
}

variable "ecr_lifecycle_keep_count" {
  description = "Number of images to keep in ECR lifecycle policy"
  type        = number
  default     = 20
}

variable "waf_rate_limit" {
  description = "WAF rate limit: maximum requests per 5-minute window per IP"
  type        = number
  default     = 2000
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarm notifications"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of availability zones to deploy NAT Gateways into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
