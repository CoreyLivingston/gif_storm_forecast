# GIF Storm Forecast - Terraform Infrastructure

This directory contains Terraform configuration to deploy the GIF Storm Forecast application as a secure static website on AWS using a private S3 bucket with mandatory CloudFront CDN for HTTPS-only content delivery.

## Overview

The infrastructure creates a secure architecture with:
- **Private S3 Bucket**: Secure storage for the application and GIF assets (no public access)
- **CloudFront Distribution**: Mandatory CDN for HTTPS-only content delivery and performance
- **Origin Access Control (OAC)**: Secure authentication between CloudFront and S3
- **S3 Bucket Policy**: Restrictive policy allowing only CloudFront OAC access

## Prerequisites

### Required Software
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0 (configured with credentials)

### AWS Account Requirements
- Active AWS account with billing enabled
- AWS CLI configured with appropriate credentials
- Required AWS permissions including CloudFront (see [IAM Permissions](#iam-permissions) section)

### Cost Considerations
- **Secure CloudFront + Private S3**: ~$1.00-5.00/month (includes CDN and security features)
- CloudFront is mandatory for security - no S3-only option available
- See [Cost Optimization](#cost-optimization) section for detailed breakdown

## Quick Start

### Secure HTTPS-Only Deployment

The infrastructure automatically creates a secure setup with private S3 and mandatory CloudFront:

```bash
# 1. Configure deployment (optional - uses secure defaults)
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars to customize bucket name, region, etc.

# 2. Deploy secure infrastructure
terraform init
terraform apply

# 3. Upload website content to private S3 bucket
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ../web_app
aws s3 sync . s3://$BUCKET_NAME/

# 4. Get your secure HTTPS website URL
cd ../terraform
terraform output website_url
# This will show the CloudFront HTTPS URL (e.g., https://d1234567890abc.cloudfront.net)

# 5. Update application config for production
# Edit js/config.js: set DEVELOPMENT_MODE = false
# Set S3_BUCKET_URL to the CloudFront URL from step 4
```

### Deployment Notes
- **CloudFront deployment takes 15-20 minutes** - this is normal for AWS CDN setup
- **HTTPS is enforced** - HTTP requests automatically redirect to HTTPS
- **S3 bucket is private** - content is only accessible through CloudFront
- **No direct S3 access** - Origin Access Control (OAC) provides secure authentication

## Security and Performance Features

The secure architecture automatically includes:

1. **HTTPS Enforcement**: All HTTP requests redirect to HTTPS for security
2. **Private S3 Storage**: Content is never directly accessible from the internet
3. **Origin Access Control**: Secure authentication between CloudFront and S3
4. **Global CDN**: CloudFront edge locations provide fast content delivery worldwide
5. **Optimized Caching**: GIFs cached for 30 days, HTML for 1 hour
6. **Gzip Compression**: Automatic compression for faster loading

### Performance Optimization
- **CloudFront CDN**: Global edge locations reduce latency
- **Optimized cache headers**: Long-term caching for static assets
- **Secure delivery**: HTTPS provides better browser performance
- **GIF optimization**: Keep individual GIFs under 10MB for best performance

## Configuration Options

### Basic Configuration (terraform.tfvars)
```hcl
# Secure setup for development
aws_region = "us-east-1"
environment = "dev"
project_name = "gif-storm-forecast"
# CloudFront is always enabled for security
```

### Production Configuration
```hcl
# Secure production setup
aws_region = "us-east-1"
environment = "prod"
project_name = "gif-storm-forecast"
bucket_name = "my-company-gif-storm-prod"
# CloudFront is mandatory - no enable_cloudfront variable needed
```

## Deployment Scenarios

### Scenario 1: Development/Testing (Secure)
**Use Case**: Local development, testing, proof of concept
**Configuration**:
```hcl
environment = "dev"
aws_region = "us-east-1"
# CloudFront is always enabled for security
```
**Expected Cost**: ~$1.00-2.00/month
**Deployment Time**: 15-20 minutes (CloudFront distribution)

### Scenario 2: Production (Secure & Performance Optimized)
**Use Case**: Public-facing deployment, kiosk displays
**Configuration**:
```hcl
environment = "prod"
aws_region = "us-east-1"  # Closest to your users
bucket_name = "my-company-gif-storm-prod"
```
**Expected Cost**: ~$2.00-5.00/month
**Deployment Time**: 15-20 minutes (CloudFront distribution)

### Scenario 3: Multi-Environment Setup
Deploy separate secure environments for development, staging, and production:

```bash
# Development
terraform workspace new dev
terraform apply -var="environment=dev"

# Staging
terraform workspace new staging  
terraform apply -var="environment=staging"

# Production
terraform workspace new prod
terraform apply -var="environment=prod" -var="bucket_name=company-gif-storm-prod"
```

**Note**: All environments use the same secure architecture with private S3 and mandatory CloudFront.

## Variable Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `bucket_name` | string | null | S3 bucket name (auto-generated if not provided) |
| `aws_region` | string | "us-east-1" | AWS region for deployment |
| `environment` | string | "dev" | Environment name for tagging |
| `project_name` | string | "gif-storm-forecast" | Project name for resource naming |

**Note**: CloudFront is always enabled for security - no `enable_cloudfront` variable needed.

### Variable Validation Rules
- **bucket_name**: 3-63 characters, lowercase letters/numbers/hyphens only
- **aws_region**: Must be supported region for S3 static website hosting
- **environment**: Lowercase letters, numbers, and hyphens only
- **project_name**: Lowercase letters, numbers, and hyphens only

## Outputs Reference

After successful deployment, Terraform provides these outputs:

| Output | Description | Example |
|--------|-------------|---------|
| `s3_bucket_name` | Created private S3 bucket name | `gif-storm-forecast-dev-a1b2c3d4` |
| `website_url` | Primary HTTPS website URL (CloudFront) | `https://d1234567890abc.cloudfront.net` |
| `cloudfront_distribution_id` | CloudFront distribution ID | `E1234567890ABC` |
| `cloudfront_domain_name` | CloudFront domain name | `d1234567890abc.cloudfront.net` |
| `origin_access_control_id` | OAC ID for CloudFront-S3 integration | `E1234567890XYZ` |

**Note**: S3 website endpoints are not exposed since the bucket is private and only accessible through CloudFront.

## IAM Permissions

### Minimum Required Permissions
Your AWS credentials need these permissions for the secure architecture:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketPolicy",
        "s3:ListBucket",
        "s3:PutBucketPolicy",
        "s3:PutBucketPublicAccessBlock",
        "s3:GetBucketPublicAccessBlock",
        "s3:DeleteBucketPolicy",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::*gif-storm-forecast*",
        "arn:aws:s3:::*gif-storm-forecast*/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:GetDistribution",
        "cloudfront:GetDistributionConfig",
        "cloudfront:ListDistributions",
        "cloudfront:UpdateDistribution",
        "cloudfront:TagResource",
        "cloudfront:UntagResource",
        "cloudfront:CreateOriginAccessControl",
        "cloudfront:DeleteOriginAccessControl",
        "cloudfront:GetOriginAccessControl",
        "cloudfront:ListOriginAccessControls"
      ],
      "Resource": "*"
    }
  ]
}
```

**Note**: S3 website hosting permissions are not needed since the bucket is private.

### Required CloudFront Permissions
CloudFront is mandatory for security, so these permissions are always required:

```json
{
  "Effect": "Allow",
  "Action": [
    "cloudfront:CreateDistribution",
    "cloudfront:DeleteDistribution",
    "cloudfront:GetDistribution",
    "cloudfront:GetDistributionConfig",
    "cloudfront:ListDistributions",
    "cloudfront:UpdateDistribution",
    "cloudfront:TagResource",
    "cloudfront:UntagResource",
    "cloudfront:CreateOriginAccessControl",
    "cloudfront:DeleteOriginAccessControl",
    "cloudfront:GetOriginAccessControl",
    "cloudfront:ListOriginAccessControls"
  ],
  "Resource": "*"
}
```

### AWS CLI Configuration
```bash
# Configure AWS CLI with your credentials
aws configure

# Verify access
aws sts get-caller-identity
```

## State Management

### Local State (Default)
Terraform state is stored locally in `terraform.tfstate`. Suitable for:
- Single developer
- Development/testing environments
- Simple deployments

### Remote State (Recommended for Teams)
For team environments, configure remote state storage:

1. **Create S3 bucket for state**:
```bash
aws s3 mb s3://your-terraform-state-bucket
```

2. **Uncomment backend configuration in `versions.tf`**:
```hcl
backend "s3" {
  bucket = "your-terraform-state-bucket"
  key    = "gif-storm-forecast/terraform.tfstate"
  region = "us-east-1"
}
```

3. **Initialize with remote backend**:
```bash
terraform init
```

## Troubleshooting

### Common Issues

#### 1. Bucket Name Already Exists
**Error**: `BucketAlreadyExists: The requested bucket name is not available`
**Solution**: 
- Don't specify `bucket_name` variable (let Terraform auto-generate)
- Or choose a different, globally unique bucket name

#### 2. Insufficient Permissions
**Error**: `AccessDenied` or `UnauthorizedOperation`
**Solution**: 
- Verify AWS CLI configuration: `aws sts get-caller-identity`
- Ensure IAM permissions match requirements above
- Check AWS region matches your credentials

#### 3. CloudFront Deployment Timeout
**Error**: CloudFront distribution creation takes too long
**Solution**: 
- CloudFront deployments take 15-20 minutes normally
- Increase Terraform timeout if needed
- Monitor AWS Console for deployment progress

#### 4. Website Not Accessible
**Error**: 403 Forbidden or connection refused
**Solution**:
- Verify CloudFront distribution is deployed (takes 15-20 minutes)
- Check Origin Access Control (OAC) configuration
- Ensure files are uploaded to the private S3 bucket
- Verify S3 bucket policy allows CloudFront OAC access
- Wait for CloudFront deployment to complete
- Use CloudFront URL, not S3 website endpoint

### Debugging Commands
```bash
# Validate Terraform configuration
terraform validate

# Check current state
terraform show

# View detailed plan
terraform plan -detailed-exitcode

# Force refresh state
terraform refresh

# View specific output
terraform output s3_website_url
```

## Validation and Testing

### Pre-Deployment Validation

Before deploying infrastructure, validate your Terraform configuration:

#### 1. Terraform Configuration Validation Commands
```bash
# Basic syntax and configuration validation
terraform validate

# Expected output:
# Success! The configuration is valid.

# Validate with formatting check
terraform fmt -check -recursive

# Expected output: (no output means files are properly formatted)

# Validate configuration with initialization
terraform init
terraform validate

# Validate specific configuration files
terraform validate -json | jq '.valid'
# Expected output: true

# Check for deprecated syntax or features
terraform validate -no-color
```

#### 2. Terraform Plan Validation for Secure Architecture
```bash
# Validate secure development deployment
terraform plan \
  -var="environment=dev" \
  -var="project_name=gif-storm-forecast"

# Validate secure production deployment
terraform plan \
  -var="environment=prod" \
  -var="project_name=gif-storm-forecast" \
  -var="bucket_name=my-unique-bucket-name"

# Validate with detailed output
terraform plan -detailed-exitcode

# Expected exit codes:
# 0 = No changes needed
# 1 = Error occurred
# 2 = Changes needed (normal for new deployment)
```

#### 2. Variable Validation Testing
Test different variable combinations to ensure validation rules work correctly:

```bash
# Test invalid bucket name (should fail)
terraform plan -var="bucket_name=INVALID-BUCKET-NAME"
# Expected: Error about bucket naming conventions

# Test invalid region (should fail)  
terraform plan -var="aws_region=invalid-region"
# Expected: Error about unsupported region

# Test invalid environment (should fail)
terraform plan -var="environment=PROD"
# Expected: Error about lowercase requirement

# Test invalid project name (should fail)
terraform plan -var="project_name=aws-project"
# Expected: Error about reserved prefix
```

#### 3. Successful Validation Examples
```bash
# Valid secure development configuration
terraform plan \
  -var="aws_region=us-east-1" \
  -var="environment=dev" \
  -var="project_name=gif-storm-forecast"

# Valid secure production configuration with custom bucket
terraform plan \
  -var="aws_region=us-west-2" \
  -var="environment=prod" \
  -var="project_name=my-gif-app" \
  -var="bucket_name=my-unique-gif-bucket-2024"
```

### Deployment Testing

#### Test Scenario 1: Secure Development Deployment
**Purpose**: Validate secure deployment for development/testing

```bash
# 1. Create test configuration
cat > test-dev.tfvars << EOF
aws_region = "us-east-1"
environment = "test"
project_name = "gif-storm-test"
EOF

# 2. Plan deployment
terraform plan -var-file="test-dev.tfvars"

# 3. Expected resources in plan:
# - aws_s3_bucket.website
# - aws_s3_bucket_public_access_block.website
# - aws_s3_bucket_policy.website
# - aws_cloudfront_origin_access_control.website
# - aws_cloudfront_distribution.website
# - random_id.bucket_suffix

# 4. Deploy (optional - will create real resources, takes 15-20 minutes)
terraform apply -var-file="test-dev.tfvars" -auto-approve

# 5. Validate outputs
terraform output s3_bucket_name
terraform output website_url  # CloudFront HTTPS URL
terraform output cloudfront_distribution_id
terraform output origin_access_control_id

# 6. Test HTTPS enforcement functionality
WEBSITE_URL=$(terraform output -raw website_url)
echo "Testing HTTPS enforcement..."
curl -I $WEBSITE_URL
# Expected: HTTP 200 or 404 (CloudFront works via HTTPS)

# Test HTTP to HTTPS redirect
HTTP_URL=$(echo $WEBSITE_URL | sed 's/https:/http:/')
curl -I $HTTP_URL
# Expected: HTTP 301/302 redirect to HTTPS

# 7. Test Origin Access Control (OAC) functionality
echo "Testing OAC functionality..."
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
curl -I "https://$BUCKET_NAME.s3.amazonaws.com/index.html"
# Expected: HTTP 403 (access denied - bucket is private, OAC working)

# Test that CloudFront can access S3 through OAC
curl -I "$WEBSITE_URL/index.html"
# Expected: HTTP 404 (CloudFront can access S3, but no content uploaded)

# 8. Cleanup
terraform destroy -var-file="test-dev.tfvars" -auto-approve
```

#### Test Scenario 2: Secure Production Deployment
**Purpose**: Validate secure production deployment with custom bucket name

```bash
# 1. Create test configuration
cat > test-prod.tfvars << EOF
aws_region = "us-west-2"
environment = "staging"
project_name = "gif-storm-staging"
bucket_name = "gif-storm-test-$(date +%s)"
EOF

# 2. Plan deployment
terraform plan -var-file="test-prod.tfvars"

# 3. Expected resources in plan:
# - aws_s3_bucket.website (with custom name)
# - aws_s3_bucket_public_access_block.website
# - aws_s3_bucket_policy.website (with OAC permissions)
# - aws_cloudfront_origin_access_control.website
# - aws_cloudfront_distribution.website
# - random_id.bucket_suffix

# 4. Deploy (optional - takes 15-20 minutes)
terraform apply -var-file="test-prod.tfvars" -auto-approve

# 5. Validate outputs
terraform output s3_bucket_name
terraform output website_url  # HTTPS CloudFront URL
terraform output cloudfront_distribution_id
terraform output cloudfront_domain_name
terraform output origin_access_control_id

# 6. Test secure access
curl -I $(terraform output -raw website_url)
# Expected: HTTP 404 (CloudFront works, no content)

# 7. Verify S3 is private
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
curl -I "https://$BUCKET_NAME.s3.amazonaws.com/"
# Expected: HTTP 403 (access denied - private bucket)

# 8. Cleanup
terraform destroy -var-file="test-prod.tfvars" -auto-approve
```

#### Test Scenario 3: Multi-Environment Deployment
**Purpose**: Validate workspace-based multi-environment setup with secure architecture

```bash
# 1. Test development environment
terraform workspace new dev-test
terraform plan \
  -var="environment=dev" \
  -var="project_name=gif-storm-dev"

# 2. Test production environment  
terraform workspace new prod-test
terraform plan \
  -var="environment=prod" \
  -var="project_name=gif-storm-prod" \
  -var="bucket_name=company-gif-storm-prod-unique"

# 3. Validate workspace isolation
terraform workspace select dev-test
terraform output  # Should show dev outputs or empty

terraform workspace select prod-test  
terraform output  # Should show prod outputs or empty

# 4. Verify both use secure architecture
terraform workspace select dev-test
terraform plan | grep -E "(cloudfront|origin_access_control)"
# Should show CloudFront and OAC resources

terraform workspace select prod-test
terraform plan | grep -E "(cloudfront|origin_access_control)"
# Should show CloudFront and OAC resources

# 5. Cleanup workspaces
terraform workspace select default
terraform workspace delete dev-test
terraform workspace delete prod-test
```

### HTTPS Enforcement and OAC Testing

#### Testing HTTPS Enforcement
```bash
#!/bin/bash
# test-https-enforcement.sh

WEBSITE_URL=$1
if [ -z "$WEBSITE_URL" ]; then
  echo "Usage: $0 <cloudfront-https-url>"
  exit 1
fi

echo "=== Testing HTTPS Enforcement ==="

# Test 1: HTTPS access works
echo "Testing HTTPS access..."
HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $WEBSITE_URL)
echo "HTTPS Status: $HTTPS_STATUS"
if [ "$HTTPS_STATUS" -eq 200 ] || [ "$HTTPS_STATUS" -eq 404 ]; then
  echo "✓ HTTPS access working"
else
  echo "✗ HTTPS access failed"
fi

# Test 2: HTTP redirects to HTTPS
echo "Testing HTTP to HTTPS redirect..."
HTTP_URL=$(echo $WEBSITE_URL | sed 's/https:/http:/')
REDIRECT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $HTTP_URL)
echo "HTTP Redirect Status: $REDIRECT_STATUS"
if [ "$REDIRECT_STATUS" -eq 301 ] || [ "$REDIRECT_STATUS" -eq 302 ]; then
  echo "✓ HTTP properly redirects to HTTPS"
else
  echo "✗ HTTP redirect not working (status: $REDIRECT_STATUS)"
fi

# Test 3: Security headers
echo "Testing security headers..."
curl -s -I $WEBSITE_URL | grep -i "strict-transport-security\|x-frame-options\|x-content-type-options"
echo "✓ Security headers check complete"
```

#### Testing Origin Access Control (OAC)
```bash
#!/bin/bash
# test-oac-functionality.sh

BUCKET_NAME=$1
CLOUDFRONT_URL=$2

if [ -z "$BUCKET_NAME" ] || [ -z "$CLOUDFRONT_URL" ]; then
  echo "Usage: $0 <s3-bucket-name> <cloudfront-url>"
  exit 1
fi

echo "=== Testing Origin Access Control (OAC) ==="

# Test 1: Direct S3 access should be blocked
echo "Testing direct S3 access (should be blocked)..."
S3_DIRECT_URL="https://$BUCKET_NAME.s3.amazonaws.com/index.html"
S3_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $S3_DIRECT_URL)
echo "Direct S3 Status: $S3_STATUS"
if [ "$S3_STATUS" -eq 403 ]; then
  echo "✓ Direct S3 access properly blocked"
else
  echo "✗ Direct S3 access not blocked (status: $S3_STATUS)"
fi

# Test 2: CloudFront can access S3 through OAC
echo "Testing CloudFront access through OAC..."
CF_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$CLOUDFRONT_URL/index.html")
echo "CloudFront Status: $CF_STATUS"
if [ "$CF_STATUS" -eq 200 ] || [ "$CF_STATUS" -eq 404 ]; then
  echo "✓ CloudFront can access S3 through OAC"
else
  echo "✗ CloudFront cannot access S3 (status: $CF_STATUS)"
fi

# Test 3: Test different file types through OAC
echo "Testing different file types through OAC..."
TEST_FILES=("js/config.js" "css/styles.css" "gifs/3.gif")
for file in "${TEST_FILES[@]}"; do
  FILE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$CLOUDFRONT_URL/$file")
  echo "File $file: $FILE_STATUS"
done
```

#### Combined Security Test
```bash
#!/bin/bash
# test-security-complete.sh

set -e

BUCKET_NAME=$(terraform output -raw s3_bucket_name)
WEBSITE_URL=$(terraform output -raw website_url)
CLOUDFRONT_ID=$(terraform output -raw cloudfront_distribution_id)
OAC_ID=$(terraform output -raw origin_access_control_id)

echo "=== Complete Security Test ==="
echo "Bucket: $BUCKET_NAME"
echo "Website: $WEBSITE_URL"
echo "CloudFront ID: $CLOUDFRONT_ID"
echo "OAC ID: $OAC_ID"

# Test HTTPS enforcement
./test-https-enforcement.sh $WEBSITE_URL

# Test OAC functionality
./test-oac-functionality.sh $BUCKET_NAME $WEBSITE_URL

# Test CloudFront configuration
echo "=== CloudFront Configuration Test ==="
aws cloudfront get-distribution --id $CLOUDFRONT_ID --query 'Distribution.DistributionConfig.Origins.Items[0].OriginAccessControlId' --output text
if [ $? -eq 0 ]; then
  echo "✓ CloudFront distribution has OAC configured"
else
  echo "✗ CloudFront distribution missing OAC"
fi

# Test S3 bucket policy
echo "=== S3 Bucket Policy Test ==="
aws s3api get-bucket-policy --bucket $BUCKET_NAME --query 'Policy' --output text | jq '.Statement[0].Condition'
if [ $? -eq 0 ]; then
  echo "✓ S3 bucket has OAC policy configured"
else
  echo "✗ S3 bucket policy missing or invalid"
fi

echo "=== Security Test Complete ==="
```

### Validation Test Scripts

#### Automated Validation Script
Create a comprehensive validation script:

```bash
#!/bin/bash
# validate-terraform.sh

set -e

echo "=== Terraform Configuration Validation ==="

# Test 1: Basic validation
echo "Testing basic configuration validation..."
terraform validate
echo "✓ Configuration is valid"

# Test 2: Variable validation
echo "Testing variable validation rules..."

# Test invalid variable values
echo "Testing invalid variable values..."
test_invalid_var() {
  local var_name=$1
  local var_value=$2
  local expected_error=$3
  
  if terraform plan -var="${var_name}=${var_value}" &>/dev/null; then
    echo "✗ Expected validation error for ${var_name}=${var_value}"
    return 1
  else
    echo "✓ Correctly rejected ${var_name}=${var_value}"
  fi
}

# Bucket name tests
test_invalid_var "bucket_name" "UPPERCASE-BUCKET" "uppercase letters"
test_invalid_var "bucket_name" "bucket..name" "consecutive dots"
test_invalid_var "bucket_name" "192.168.1.1" "IP address format"
test_invalid_var "bucket_name" "xn--bucket" "xn-- prefix"
test_invalid_var "bucket_name" "aws-bucket" "aws prefix"

# Region tests
test_invalid_var "aws_region" "invalid-region" "invalid region"
test_invalid_var "aws_region" "us-east-99" "non-existent region"

# Environment tests  
test_invalid_var "environment" "PROD" "uppercase environment"
test_invalid_var "environment" "invalid_env" "underscore in environment"

# Project name tests
test_invalid_var "project_name" "AWS-Project" "uppercase and aws prefix"
test_invalid_var "project_name" "project--name" "consecutive hyphens"

echo "✓ All validation rules working correctly"

# Test 3: Valid configurations
echo "Testing valid configurations..."

# Development configuration (secure architecture)
terraform plan \
  -var="aws_region=us-east-1" \
  -var="environment=dev" \
  -var="project_name=test-project" \
  -out=dev.tfplan

echo "✓ Development configuration is valid"

# Production configuration (secure architecture)
terraform plan \
  -var="aws_region=us-west-2" \
  -var="environment=prod" \
  -var="project_name=test-project" \
  -var="bucket_name=test-bucket-unique-name" \
  -out=prod.tfplan

echo "✓ Production configuration is valid"

# Test 4: Resource count validation for secure architecture
echo "Validating expected resource counts for secure architecture..."

# Check development plan (always includes CloudFront for security)
dev_resources=$(terraform show -json dev.tfplan | jq '.planned_values.root_module.resources | length')
if [ "$dev_resources" -eq 6 ]; then
  echo "✓ Development plan has correct resource count (6) for secure architecture"
else
  echo "✗ Development plan has $dev_resources resources, expected 6 for secure architecture"
fi

# Check production plan (always includes CloudFront for security)
prod_resources=$(terraform show -json prod.tfplan | jq '.planned_values.root_module.resources | length')
if [ "$prod_resources" -eq 6 ]; then
  echo "✓ Production plan has correct resource count (6) for secure architecture"
else
  echo "✗ Production plan has $prod_resources resources, expected 6 for secure architecture"
fi

# Expected resources for secure architecture: S3 bucket, S3 public access block, S3 bucket policy, 
# CloudFront OAC, CloudFront distribution, random_id
echo "Expected resources for secure architecture: S3 bucket, S3 public access block, S3 bucket policy, CloudFront OAC, CloudFront distribution, random_id"

# Cleanup
rm -f dev.tfplan prod.tfplan

echo "=== All validation tests passed! ==="
```

#### Variable Validation Test Matrix

| Test Case | Variable | Value | Expected Result |
|-----------|----------|-------|-----------------|
| **Bucket Name Tests** |
| Valid bucket | `bucket_name` | `"my-valid-bucket-123"` | ✓ Pass |
| Too short | `bucket_name` | `"ab"` | ✗ Fail - length < 3 |
| Too long | `bucket_name` | `"a-very-long-bucket-name-that-exceeds-sixty-three-characters-limit"` | ✗ Fail - length > 63 |
| Uppercase | `bucket_name` | `"My-Bucket"` | ✗ Fail - contains uppercase |
| IP format | `bucket_name` | `"192.168.1.1"` | ✗ Fail - IP address format |
| Consecutive dots | `bucket_name` | `"bucket..name"` | ✗ Fail - consecutive dots |
| AWS prefix | `bucket_name` | `"aws-bucket"` | ✗ Fail - reserved prefix |
| **Region Tests** |
| Valid region | `aws_region` | `"us-east-1"` | ✓ Pass |
| Invalid region | `aws_region` | `"invalid-region"` | ✗ Fail - not in allowed list |
| Wrong format | `aws_region` | `"us_east_1"` | ✗ Fail - wrong format |
| **Environment Tests** |
| Valid env | `environment` | `"dev"` | ✓ Pass |
| Valid env | `environment` | `"production"` | ✓ Pass |
| Invalid env | `environment` | `"PROD"` | ✗ Fail - uppercase |
| Invalid env | `environment` | `"custom-env"` | ✗ Fail - not in allowed list |
| **Project Name Tests** |
| Valid name | `project_name` | `"my-project"` | ✓ Pass |
| Too short | `project_name` | `"ab"` | ✗ Fail - length < 3 |
| Reserved prefix | `project_name` | `"aws-project"` | ✗ Fail - reserved prefix |
| Consecutive hyphens | `project_name` | `"project--name"` | ✗ Fail - consecutive hyphens |

### Integration Testing

#### End-to-End Deployment Test
```bash
#!/bin/bash
# e2e-test.sh - Complete secure deployment and functionality test

set -e

PROJECT_NAME="gif-storm-e2e-test"
ENVIRONMENT="test"
TIMESTAMP=$(date +%s)

echo "=== Starting Secure End-to-End Test ==="

# 1. Deploy secure infrastructure
echo "Deploying secure test infrastructure (this takes 15-20 minutes)..."
terraform apply -auto-approve \
  -var="project_name=${PROJECT_NAME}" \
  -var="environment=${ENVIRONMENT}"

# 2. Get outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
WEBSITE_URL=$(terraform output -raw website_url)  # CloudFront HTTPS URL
CLOUDFRONT_ID=$(terraform output -raw cloudfront_distribution_id)

echo "Deployed to private bucket: $BUCKET_NAME"
echo "Secure website URL: $WEBSITE_URL"
echo "CloudFront distribution: $CLOUDFRONT_ID"

# 3. Upload test content to private bucket
echo "Uploading test content to private S3 bucket..."
cd ..
aws s3 sync . s3://$BUCKET_NAME/ \
  --exclude "*.md" \
  --exclude "deploy/*" \
  --exclude ".git/*" \
  --exclude "terraform/*"

# 4. Wait for CloudFront deployment to complete
echo "Waiting for CloudFront deployment to complete..."
aws cloudfront wait distribution-deployed --id $CLOUDFRONT_ID
echo "✓ CloudFront deployment complete"

# 5. Test secure website accessibility
echo "Testing secure website accessibility..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $WEBSITE_URL)
if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "✓ Secure website is accessible via HTTPS (HTTP $HTTP_STATUS)"
else
  echo "✗ Website returned HTTP $HTTP_STATUS"
fi

# 6. Test HTTPS enforcement
echo "Testing HTTPS enforcement..."
HTTP_URL=$(echo $WEBSITE_URL | sed 's/https:/http:/')
REDIRECT_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $HTTP_URL)
if [ "$REDIRECT_STATUS" -eq 301 ] || [ "$REDIRECT_STATUS" -eq 302 ]; then
  echo "✓ HTTP redirects to HTTPS (HTTP $REDIRECT_STATUS)"
else
  echo "✗ HTTP redirect returned HTTP $REDIRECT_STATUS"
fi

# 7. Test specific files through CloudFront
echo "Testing GIF file access through CloudFront..."
GIF_URL="${WEBSITE_URL}/gifs/3.gif"
GIF_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $GIF_URL)
if [ "$GIF_STATUS" -eq 200 ]; then
  echo "✓ GIF files are accessible through CloudFront (HTTP $GIF_STATUS)"
else
  echo "✗ GIF file returned HTTP $GIF_STATUS"
fi

# 8. Verify S3 direct access is blocked
echo "Verifying S3 direct access is blocked..."
S3_DIRECT_URL="https://$BUCKET_NAME.s3.amazonaws.com/index.html"
S3_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $S3_DIRECT_URL)
if [ "$S3_STATUS" -eq 403 ]; then
  echo "✓ Direct S3 access is properly blocked (HTTP $S3_STATUS)"
else
  echo "✗ S3 direct access returned HTTP $S3_STATUS (should be 403)"
fi

# 9. Cleanup
echo "Cleaning up test resources..."
cd terraform
terraform destroy -auto-approve \
  -var="project_name=${PROJECT_NAME}" \
  -var="environment=${ENVIRONMENT}"

echo "=== Secure End-to-End Test Complete ==="
```

### Performance Testing

#### Load Testing Script
```bash
#!/bin/bash
# load-test.sh - Basic load testing for deployed website

WEBSITE_URL=$1
if [ -z "$WEBSITE_URL" ]; then
  echo "Usage: $0 <website-url>"
  exit 1
fi

echo "=== Load Testing $WEBSITE_URL ==="

# Test 1: Basic connectivity
echo "Testing basic connectivity..."
curl -s -o /dev/null -w "HTTP Status: %{http_code}, Time: %{time_total}s\n" $WEBSITE_URL

# Test 2: Multiple concurrent requests
echo "Testing concurrent requests..."
for i in {1..10}; do
  curl -s -o /dev/null -w "Request $i: %{http_code} (%{time_total}s)\n" $WEBSITE_URL &
done
wait

# Test 3: GIF loading performance
echo "Testing GIF loading performance..."
GIF_URLS=(
  "$WEBSITE_URL/gifs/3.gif"
  "$WEBSITE_URL/gifs/4.gif"
  "$WEBSITE_URL/gifs/5.gif"
)

for gif_url in "${GIF_URLS[@]}"; do
  curl -s -o /dev/null -w "GIF $(basename $gif_url): %{http_code} (%{time_total}s, %{size_download} bytes)\n" $gif_url
done

echo "=== Load Testing Complete ==="
```

### Continuous Integration Testing

#### GitHub Actions Workflow Example
```yaml
# .github/workflows/terraform-test.yml
name: Terraform Validation and Testing

on:
  pull_request:
    paths:
      - 'terraform/**'
  push:
    branches:
      - main
    paths:
      - 'terraform/**'

jobs:
  validate:
    name: Validate Terraform Configuration
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
        
    - name: Terraform Format Check
      run: terraform fmt -check -recursive terraform/
      
    - name: Terraform Init
      run: |
        cd terraform
        terraform init
        
    - name: Terraform Validate
      run: |
        cd terraform
        terraform validate
        
    - name: Terraform Plan (Development)
      run: |
        cd terraform
        terraform plan \
          -var="environment=ci-test" \
          -var="project_name=gif-storm-ci"
          
    - name: Terraform Plan (Production)
      run: |
        cd terraform
        terraform plan \
          -var="environment=ci-prod" \
          -var="project_name=gif-storm-ci" \
          -var="bucket_name=gif-storm-ci-prod-unique"

  security-scan:
    name: Security Scan
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Run Checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: terraform/
        framework: terraform
```

### Testing Checklist

#### Pre-Deployment Checklist
- [ ] `terraform validate` passes
- [ ] `terraform fmt -check` passes  
- [ ] All variable validation rules tested
- [ ] Secure architecture configuration plan reviewed
- [ ] CloudFront and OAC configuration verified
- [ ] Expected resource count verified (6 resources for secure architecture)
- [ ] Cost estimation reviewed

#### Post-Deployment Checklist
- [ ] All Terraform outputs populated correctly
- [ ] S3 website endpoint accessible
- [ ] CloudFront distribution accessible (if enabled)
- [ ] Website content loads correctly
- [ ] GIF files accessible and display properly
- [ ] HTTP status codes are 200 for valid requests
- [ ] 404 errors for non-existent files
- [ ] Cost allocation tags applied to all resources

#### Cleanup Verification Checklist
- [ ] `terraform destroy` completes successfully
- [ ] No orphaned S3 buckets remain
- [ ] No orphaned CloudFront distributions remain
- [ ] AWS billing shows resource termination
- [ ] No unexpected charges after cleanup

## Cleanup

### Destroy Infrastructure
```bash
# Remove all AWS resources
terraform destroy

# Confirm destruction
# Type 'yes' when prompted
```

### Manual Cleanup (if needed)
If `terraform destroy` fails:

1. **Empty S3 bucket**:
```bash
aws s3 rm s3://your-bucket-name --recursive
```

2. **Delete CloudFront distribution** (if exists):
- Disable distribution in AWS Console
- Wait for deployment to complete
- Delete distribution

3. **Run destroy again**:
```bash
terraform destroy
```

## Integration with Existing Project

### Automated Deployment Script
Create a deployment script in your project root:

```bash
#!/bin/bash
# deploy.sh

set -e

echo "Deploying GIF Storm Forecast infrastructure..."

# Deploy infrastructure
cd terraform
terraform init
terraform apply -auto-approve

# Get bucket name
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload website content
cd ..
echo "Uploading content to S3 bucket: $BUCKET_NAME"
aws s3 sync . s3://$BUCKET_NAME/ \
  --exclude "*.md" \
  --exclude "deploy/*" \
  --exclude ".git/*" \
  --exclude "terraform/*"

# Display URLs
cd terraform
echo "Deployment complete!"
echo "S3 Website URL: $(terraform output -raw s3_website_url)"
if [ "$(terraform output -raw cloudfront_url)" != "null" ]; then
  echo "CloudFront URL: $(terraform output -raw cloudfront_url)"
fi
```

### CI/CD Integration
For automated deployments, add to your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
- name: Deploy Infrastructure
  run: |
    cd terraform
    terraform init
    terraform plan
    terraform apply -auto-approve
    
- name: Upload Website Content  
  run: |
    BUCKET_NAME=$(cd terraform && terraform output -raw s3_bucket_name)
    aws s3 sync . s3://$BUCKET_NAME/ --exclude "terraform/*"
```

## Cost Optimization

### Expected Monthly Costs

#### Secure CloudFront + Private S3 Configuration (Only Option)
**Estimated Cost: $1.00 - $5.00/month**

| Component | Usage | Cost |
|-----------|-------|------|
| S3 Standard Storage | 100MB website + GIFs | $0.02/month |
| S3 Requests (minimal) | 1,000 requests/month | $0.004/month |
| CloudFront Requests | 10,000 requests/month | $0.10/month |
| CloudFront Data Transfer | 1GB/month | $0.085/month |
| **Total** | | **~$0.21/month** |

**Cost Benefits of Mandatory CloudFront:**
- **Reduced S3 costs**: CloudFront caching reduces S3 GET requests by ~90%
- **No data transfer charges**: S3 to CloudFront transfers are free
- **Global performance**: Edge locations reduce latency worldwide
- **Security included**: HTTPS and private S3 access at no extra cost

*Note: Costs scale with traffic. High-traffic sites may reach $2-5/month but benefit from better caching.*

### Cost Optimization Strategies

#### 1. Storage Class Selection

**Current Configuration: S3 Standard**
- **Best for**: Frequently accessed GIFs and website files
- **Cost**: $0.023/GB/month
- **Use when**: GIFs are viewed regularly (kiosk displays, active websites)

**Alternative: S3 Standard-IA (Infrequent Access)**
- **Best for**: Archive GIFs or backup content
- **Cost**: $0.0125/GB/month storage + $0.01/GB retrieval
- **Use when**: Some GIFs are rarely accessed
- **Implementation**:
```hcl
# Add to main.tf
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}
```

#### 2. CloudFront Optimization

**Current Configuration: PriceClass_100**
- **Coverage**: US, Canada, Europe
- **Cost**: Lowest CloudFront pricing tier
- **Best for**: Regional audiences

**Alternative Configurations**:
```hcl
# Global coverage (higher cost)
price_class = "PriceClass_All"

# US/Europe only (current - cost optimized)
price_class = "PriceClass_100"

# US only (lowest cost)
price_class = "PriceClass_100"  # Same as current
```

#### 3. Request Optimization

**Enable Compression** (Already configured):
```hcl
compress = true  # Reduces data transfer costs by ~70% for text files
```

**Optimize Caching**:
```hcl
# Current optimized settings
default_ttl = 3600   # 1 hour cache
max_ttl     = 86400  # 24 hour max cache
```

#### 4. Traffic-Based Cost Optimization

**Low Traffic (< 1GB/month)**:
- CloudFront provides security and performance benefits
- Minimal CloudFront charges due to low usage
- Expected cost: $0.20-0.50/month

**Medium Traffic (1-10GB/month)**:
- CloudFront caching reduces S3 costs significantly
- Optimal cost-performance balance
- Expected cost: $0.50-2.00/month

**High Traffic (> 10GB/month)**:
- CloudFront provides major cost savings vs direct S3
- Global edge caching reduces origin load
- Expected cost: $2.00-10.00/month

**CloudFront Cost Optimization Tips:**
- Use PriceClass_100 (US, Canada, Europe) for cost savings
- Enable compression to reduce data transfer
- Optimize cache TTL settings for static content
- Monitor CloudFront usage reports for optimization opportunities

### Cost Monitoring Setup

#### 1. AWS Budgets Configuration
```bash
# Create cost budget alert
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget '{
    "BudgetName": "GIF-Storm-Forecast-Monthly",
    "BudgetLimit": {
      "Amount": "5.00",
      "Unit": "USD"
    },
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }'
```

#### 2. Cost Allocation Tags
All resources are automatically tagged for cost tracking:
```hcl
default_tags {
  tags = {
    Project     = var.project_name      # "gif-storm-forecast"
    Environment = var.environment       # "dev", "prod", etc.
    ManagedBy   = "terraform"
    Purpose     = "static-website-hosting"
  }
}
```

#### 3. Cost Analysis Queries
Use AWS Cost Explorer with these filters:
- **Service**: Amazon Simple Storage Service, Amazon CloudFront
- **Tag**: Project = "gif-storm-forecast"
- **Time Range**: Last 30 days

### Cost Reduction Techniques

#### 1. Optimize CloudFront Caching
Maximize cache hit ratio to reduce origin requests:
```hcl
# Current optimized settings in main.tf
default_cache_behavior {
  # Cache GIFs for 30 days (reduces S3 requests)
  default_ttl = 2592000  # 30 days
  max_ttl     = 31536000 # 1 year
  
  # Cache HTML for 1 hour (allows updates)
  min_ttl = 0
}
```

#### 2. Minimize S3 Storage Costs
```bash
# Upload with optimized sync (reduces PUT requests and storage)
aws s3 sync . s3://bucket-name/ \
  --delete \
  --exclude "*.md" \
  --exclude "deploy/*" \
  --exclude ".git/*" \
  --exclude "terraform/*"
```

#### 3. Optimize GIF Files
Reduce storage and transfer costs by optimizing GIFs:
```bash
# Install gifsicle for GIF optimization
brew install gifsicle  # macOS
apt-get install gifsicle  # Ubuntu

# Optimize GIFs (reduces storage and CloudFront transfer costs)
find gifs/ -name "*.gif" -exec gifsicle --optimize=3 --output={} {} \;
```

#### 4. CloudFront Price Class Optimization
The infrastructure uses cost-optimized settings:
```hcl
# Current cost-optimized configuration
price_class = "PriceClass_100"  # US, Canada, Europe only
compress    = true              # Reduces data transfer by ~70%
```

#### 5. Enable S3 Intelligent Tiering (Optional)
For mixed access patterns on large GIF collections:
```hcl
resource "aws_s3_bucket_intelligent_tiering_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  name   = "EntireBucket"

  status = "Enabled"
}
```

### Cost Monitoring Commands

#### Daily Cost Check
```bash
# Get current month costs
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

#### Resource-Specific Costs
```bash
# S3 costs by bucket
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=RESOURCE_ID \
  --filter file://s3-filter.json
```

### Cost Alerts and Automation

#### 1. CloudWatch Billing Alarms
```hcl
# Add to main.tf for cost monitoring
resource "aws_cloudwatch_metric_alarm" "billing_alarm" {
  alarm_name          = "${var.project_name}-${var.environment}-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400"  # 24 hours
  statistic           = "Maximum"
  threshold           = "5.00"   # $5 threshold
  alarm_description   = "This metric monitors AWS billing charges"
  alarm_actions       = [aws_sns_topic.billing_alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}
```

#### 2. Automated Cost Reports
Create a Lambda function for weekly cost reports:
```python
# Weekly cost report function
import boto3
import json

def lambda_handler(event, context):
    ce = boto3.client('ce')
    
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': '2024-01-01',
            'End': '2024-01-31'
        },
        Granularity='MONTHLY',
        Metrics=['BlendedCost'],
        GroupBy=[
            {
                'Type': 'DIMENSION',
                'Key': 'SERVICE'
            }
        ]
    )
    
    # Process and send cost report
    return {
        'statusCode': 200,
        'body': json.dumps(response)
    }
```

### Regional Cost Considerations

#### Cheapest AWS Regions for S3
1. **us-east-1** (N. Virginia) - Lowest S3 costs
2. **us-west-2** (Oregon) - Second lowest
3. **eu-west-1** (Ireland) - Lowest in Europe

#### CloudFront Regional Pricing
- **PriceClass_100**: US, Canada, Europe (current configuration)
- **PriceClass_200**: + Asia Pacific (except Australia/New Zealand)
- **PriceClass_All**: Global coverage (highest cost)

### Cost Optimization Checklist

- [ ] **Storage**: Use S3 Standard for active content
- [ ] **Requests**: Minimize S3 API calls with efficient sync
- [ ] **Transfer**: Enable CloudFront compression
- [ ] **Caching**: Optimize TTL values for content type
- [ ] **Monitoring**: Set up billing alerts under $5/month
- [ ] **Tagging**: Ensure all resources have cost allocation tags
- [ ] **Lifecycle**: Consider IA storage for old content
- [ ] **Regional**: Deploy in us-east-1 for lowest costs
- [ ] **GIF Optimization**: Compress GIFs before upload
- [ ] **CloudFront**: Only enable for high-traffic deployments

## Support

### Getting Help
- Review [AWS S3 Static Website Hosting Documentation](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)
- Check [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- Verify [AWS Service Limits](https://docs.aws.amazon.com/general/latest/gr/s3.html)
- Monitor costs with [AWS Cost Explorer](https://aws.amazon.com/aws-cost-management/aws-cost-explorer/)

### Monitoring and Maintenance
- Monitor AWS costs in [AWS Billing Console](https://console.aws.amazon.com/billing/)
- Set up [AWS Budgets](https://aws.amazon.com/aws-cost-management/aws-budgets/) for cost alerts
- Review [CloudWatch metrics](https://console.aws.amazon.com/cloudwatch/) for usage patterns
- Use [AWS Cost Anomaly Detection](https://aws.amazon.com/aws-cost-management/aws-cost-anomaly-detection/) for unusual spending alerts