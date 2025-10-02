# Design Document

## Overview

This design outlines the Terraform infrastructure-as-code solution for deploying the GIF Storm Forecast application as a cost-effective static website on AWS. The solution focuses on a simple S3-only setup for minimal cost and maximum simplicity, with an optional CloudFront CDN for improved performance if needed.

The infrastructure follows AWS best practices for static website hosting while prioritizing cost optimization and ease of deployment. The design uses modular Terraform configuration with clear variable definitions and comprehensive outputs.

## Architecture

### Primary Architecture (S3 Only)
```
Internet → S3 Bucket (Static Website Hosting) → GIF Storm Forecast App
```

### Optional Enhanced Architecture (S3 + CloudFront)
```
Internet → CloudFront Distribution → S3 Bucket → GIF Storm Forecast App
```

### Key Components

1. **S3 Bucket**: Primary storage for static website files and GIF assets
2. **S3 Bucket Policy**: Public read access for website content
3. **S3 Website Configuration**: Static website hosting with index document
4. **CloudFront Distribution** (Optional): CDN for performance optimization only
5. **Origin Access Control** (Optional): Secure S3 access when using CloudFront

## Components and Interfaces

### Terraform Configuration Structure

```
terraform/
├── main.tf                 # Main resource definitions
├── variables.tf            # Input variable definitions
├── outputs.tf             # Output value definitions
├── versions.tf            # Provider version constraints
├── terraform.tfvars.example # Example variable values
└── README.md              # Deployment instructions
```

### Core Resources

#### S3 Bucket Configuration
- **Resource**: `aws_s3_bucket`
- **Purpose**: Primary storage for website files and GIF assets
- **Configuration**: 
  - Unique bucket name with configurable prefix
  - Force destroy enabled for easy cleanup
  - Appropriate tags for cost tracking

#### S3 Website Configuration
- **Resource**: `aws_s3_bucket_website_configuration`
- **Purpose**: Enable static website hosting
- **Configuration**:
  - Index document: `index.html`
  - Error document: `index.html` (SPA behavior)

#### S3 Public Access Configuration
- **Resource**: `aws_s3_bucket_public_access_block`
- **Purpose**: Allow public read access for website hosting
- **Configuration**:
  - Disable block public ACLs and policies for website access
  - Maintain security best practices

#### S3 Bucket Policy
- **Resource**: `aws_s3_bucket_policy`
- **Purpose**: Grant public read access to website content
- **Configuration**:
  - Allow `s3:GetObject` for all objects in bucket
  - Principal: `*` (public access)

#### CloudFront Distribution (Optional)
- **Resource**: `aws_cloudfront_distribution`
- **Purpose**: CDN for performance optimization
- **Configuration**:
  - Origin: S3 website endpoint
  - Price class: `PriceClass_100` (cost-optimized)
  - Default root object: `index.html`
  - Viewer protocol policy: `allow-all` (HTTP and HTTPS both allowed)

### Variable Interface

```hcl
variable "bucket_name" {
  description = "Name of the S3 bucket for static website hosting"
  type        = string
  default     = null  # Auto-generated if not provided
}

variable "aws_region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "us-east-1"
}

variable "enable_cloudfront" {
  description = "Enable CloudFront CDN for improved performance (optional)"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "gif-storm-forecast"
}
```

### Output Interface

```hcl
output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "s3_website_endpoint" {
  description = "S3 website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "s3_website_url" {
  description = "Complete S3 website URL"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "cloudfront_url" {
  description = "Complete CloudFront URL"
  value       = var.enable_cloudfront ? "http://${aws_cloudfront_distribution.website[0].domain_name}" : null
}
```

## Data Models

### Resource Naming Convention
- **S3 Bucket**: `{project_name}-{environment}-{random_suffix}`
- **CloudFront Distribution**: `{project_name}-{environment}-cdn`
- **Tags**: Consistent across all resources

### Tag Schema
```hcl
{
  Project     = var.project_name
  Environment = var.environment
  ManagedBy   = "terraform"
  Purpose     = "static-website-hosting"
}
```

### Cost Optimization Strategy

#### S3 Configuration
- **Storage Class**: Standard (for frequently accessed content)
- **Lifecycle Policy**: Not implemented initially (GIFs are frequently accessed)
- **Versioning**: Disabled to reduce storage costs
- **Transfer Acceleration**: Disabled (not needed for static hosting)

#### CloudFront Configuration (When Enabled)
- **Price Class**: `PriceClass_100` (US, Canada, Europe only)
- **Caching**: Optimized for static content with long TTL
- **Compression**: Enabled for text-based files
- **Origin Shield**: Disabled (not cost-effective for small sites)
- **Protocol**: HTTP allowed (no HTTPS requirement)

## Error Handling

### Terraform Error Scenarios

1. **Bucket Name Conflicts**
   - **Issue**: S3 bucket names must be globally unique
   - **Solution**: Use random suffix generation with `random_id` resource
   - **Fallback**: Provide clear error message with suggested alternatives

2. **Region-Specific Limitations**
   - **Issue**: Some AWS services have regional limitations
   - **Solution**: Validate region compatibility in variables
   - **Documentation**: Clear region requirements in README

3. **Permission Errors**
   - **Issue**: Insufficient AWS permissions for resource creation
   - **Solution**: Provide comprehensive IAM policy requirements
   - **Documentation**: Minimum required permissions list

4. **CloudFront Deployment Time**
   - **Issue**: CloudFront distributions take 15+ minutes to deploy
   - **Solution**: Set appropriate timeouts and provide user expectations
   - **Monitoring**: Include deployment status in outputs

### Resource Dependencies

```hcl
# Explicit dependency chain
aws_s3_bucket → aws_s3_bucket_website_configuration
aws_s3_bucket → aws_s3_bucket_public_access_block
aws_s3_bucket → aws_s3_bucket_policy
aws_s3_bucket → aws_cloudfront_distribution (if enabled)
```

## Testing Strategy

### Validation Tests

1. **Terraform Validation**
   - `terraform validate` - Syntax and configuration validation
   - `terraform plan` - Resource planning validation
   - Variable validation rules for required inputs

2. **Resource Creation Tests**
   - S3 bucket creation and configuration
   - Website hosting enablement
   - Public access configuration
   - CloudFront distribution (when enabled)

3. **Functional Tests**
   - S3 website endpoint accessibility
   - CloudFront distribution functionality (when enabled)
   - HTTP content delivery verification
   - GIF loading and display functionality

### Cost Validation

1. **Resource Cost Estimation**
   - Use `terraform plan` with cost estimation tools
   - Validate price class selections
   - Confirm minimal resource configuration

2. **Ongoing Cost Monitoring**
   - Implement cost allocation tags
   - Provide cost monitoring recommendations
   - Document expected monthly costs

### Security Testing

1. **Access Control Validation**
   - Verify public read access works correctly
   - Confirm no unintended write permissions
   - Validate CloudFront origin access control

2. **Content Delivery Validation**
   - Test HTTP content delivery
   - Verify CloudFront caching behavior (when enabled)
   - Validate static asset loading

### Deployment Testing

1. **Multi-Environment Testing**
   - Test with different variable configurations
   - Validate resource naming conventions
   - Confirm tag application

2. **Cleanup Testing**
   - Verify `terraform destroy` removes all resources
   - Test force destroy functionality for S3 bucket
   - Confirm no orphaned resources remain

### Integration Testing

1. **Application Deployment**
   - Test file upload to created S3 bucket
   - Verify website functionality after deployment
   - Validate GIF loading and slideshow operation

2. **CI/CD Integration**
   - Test Terraform execution in automated pipelines
   - Validate state management configuration
   - Confirm output value accessibility