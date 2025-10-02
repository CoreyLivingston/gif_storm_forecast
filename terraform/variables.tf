variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting. If not provided, a unique name will be generated."
  type        = string
  default     = null

  validation {
    condition = var.bucket_name == null || (
      length(var.bucket_name) >= 3 &&
      length(var.bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.bucket_name)) &&
      !can(regex("\\.\\.|\\.\\-|\\-\\.", var.bucket_name)) &&
      !can(regex("^\\d+\\.\\d+\\.\\d+\\.\\d+$", var.bucket_name)) &&
      !can(regex("^xn--", var.bucket_name)) &&
      !can(regex("-s3alias$", var.bucket_name))
    )
    error_message = "Bucket name must be between 3 and 63 characters, contain only lowercase letters, numbers, dots, and hyphens, follow AWS naming conventions, not be formatted as an IP address, not start with 'xn--', and not end with '-s3alias'."
  }

  validation {
    condition = var.bucket_name == null || !can(regex("^(amazon|aws)", var.bucket_name))
    error_message = "Bucket name cannot start with 'amazon' or 'aws' as these are reserved prefixes."
  }
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"

  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-west-2", "eu-west-3", "eu-central-1", "eu-central-2",
      "eu-north-1", "eu-south-1", "eu-south-2",
      "ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ap-southeast-4",
      "ap-northeast-1", "ap-northeast-2", "ap-northeast-3",
      "ap-south-1", "ap-south-2", "ap-east-1",
      "ca-central-1", "ca-west-1",
      "sa-east-1",
      "af-south-1",
      "me-south-1", "me-central-1",
      "il-central-1"
    ], var.aws_region)
    error_message = "AWS region must be a valid region where S3 static website hosting is supported. See AWS documentation for current list of supported regions."
  }

  validation {
    condition = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "AWS region must follow the format: two lowercase letters, dash, region name, dash, and number (e.g., us-east-1)."
  }
}

variable "enable_cloudfront" {
  description = "Enable CloudFront CDN for improved performance and HTTPS support"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name for resource tagging (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition = (
      length(var.environment) >= 2 &&
      length(var.environment) <= 20 &&
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.environment))
    )
    error_message = "Environment must be 2-20 characters, start with a lowercase letter, end with a letter or number, and contain only lowercase letters, numbers, and hyphens."
  }

  validation {
    condition = contains([
      "dev", "development", "test", "testing", "stage", "staging", 
      "prod", "production", "demo", "sandbox", "qa", "uat"
    ], var.environment)
    error_message = "Environment must be one of: dev, development, test, testing, stage, staging, prod, production, demo, sandbox, qa, uat."
  }
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "gif-storm-forecast"

  validation {
    condition = (
      length(var.project_name) >= 3 &&
      length(var.project_name) <= 50 &&
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_name)) &&
      !can(regex("--", var.project_name))
    )
    error_message = "Project name must be 3-50 characters, start with a lowercase letter, end with a letter or number, contain only lowercase letters, numbers, and single hyphens (no consecutive hyphens)."
  }

  validation {
    condition = !can(regex("^(aws|amazon|s3|cloudfront|terraform)", var.project_name))
    error_message = "Project name cannot start with reserved prefixes: aws, amazon, s3, cloudfront, terraform."
  }
}