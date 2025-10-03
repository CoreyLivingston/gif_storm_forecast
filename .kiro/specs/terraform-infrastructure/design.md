# Design Document

## Overview

This design outlines the Terraform infrastructure-as-code solution for deploying the GIF Storm Forecast application as a secure static website on AWS. The solution uses a private S3 bucket for content storage with mandatory CloudFront distribution for HTTPS-only content delivery, implementing Origin Access Control (OAC) for secure access.

The infrastructure follows AWS security best practices by eliminating public S3 access and enforcing HTTPS-only delivery. The design uses modular Terraform configuration with comprehensive security controls and clear variable definitions.

## Architecture

### Secure Architecture (CloudFront + Private S3)
```
Internet → CloudFront Distribution (HTTPS) → Origin Access Control → Private S3 Bucket → GIF Storm Forecast App
```

### Key Components

1. **Private S3 Bucket**: Secure storage for static website files and GIF assets (no public access)
2. **CloudFront Distribution**: Mandatory CDN for HTTPS content delivery and performance
3. **Origin Access Control (OAC)**: Secure authentication between CloudFront and S3
4. **S3 Bucket Policy**: Restrictive policy allowing only CloudFront OAC access
5. **CloudFront Security Headers**: HTTPS enforcement and security best practices

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

#### S3 Public Access Block
- **Resource**: `aws_s3_bucket_public_access_block`
- **Purpose**: Block all public access to ensure security
- **Configuration**:
  - Enable all public access block settings
  - Prevent any public access to bucket or objects

#### Origin Access Control
- **Resource**: `aws_cloudfront_origin_access_control`
- **Purpose**: Secure authentication between CloudFront and S3
- **Configuration**:
  - Origin type: S3
  - Signing behavior: Always sign requests
  - Signing protocol: sigv4

#### S3 Bucket Policy
- **Resource**: `aws_s3_bucket_policy`
- **Purpose**: Grant access only to CloudFront via OAC
- **Configuration**:
  - Allow `s3:GetObject` for CloudFront OAC identity only
  - Principal: CloudFront service with OAC condition

#### CloudFront Distribution (Mandatory)
- **Resource**: `aws_cloudfront_distribution`
- **Purpose**: Secure HTTPS content delivery and performance optimization
- **Configuration**:
  - Origin: S3 bucket domain name (not website endpoint)
  - Origin Access Control: Configured OAC identity
  - Price class: `PriceClass_100` (cost-optimized)
  - Default root object: `index.html`
  - Viewer protocol policy: `redirect-to-https` (HTTPS enforcement)

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

# CloudFront is now mandatory - no enable_cloudfront variable needed

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

output "website_url" {
  description = "Primary HTTPS website URL via CloudFront"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

output "origin_access_control_id" {
  description = "Origin Access Control ID for CloudFront-S3 integration"
  value       = aws_cloudfront_origin_access_control.website.id
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

#### CloudFront Configuration (Always Enabled)
- **Price Class**: `PriceClass_100` (US, Canada, Europe only)
- **Caching**: Optimized for static content with long TTL
- **Compression**: Enabled for text-based files, disabled for GIFs
- **Origin Shield**: Disabled (not cost-effective for small sites)
- **Protocol**: HTTPS enforced (HTTP redirects to HTTPS)
- **Origin Access Control**: Secure S3 access without public permissions

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
aws_s3_bucket → aws_s3_bucket_public_access_block
aws_cloudfront_origin_access_control → aws_s3_bucket_policy
aws_cloudfront_origin_access_control → aws_cloudfront_distribution
aws_s3_bucket → aws_cloudfront_distribution
```

## Testing Strategy

### Validation Tests

1. **Terraform Validation**
   - `terraform validate` - Syntax and configuration validation
   - `terraform plan` - Resource planning validation
   - Variable validation rules for required inputs

2. **Resource Creation Tests**
   - S3 bucket creation with private access
   - Origin Access Control creation
   - CloudFront distribution deployment
   - S3 bucket policy with OAC permissions

3. **Functional Tests**
   - CloudFront HTTPS endpoint accessibility
   - Origin Access Control functionality
   - HTTPS enforcement (HTTP redirect) verification
   - GIF loading and display functionality through CloudFront

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
   - Test HTTPS-only content delivery
   - Verify CloudFront caching behavior
   - Validate static asset loading through OAC
   - Confirm direct S3 access is blocked

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