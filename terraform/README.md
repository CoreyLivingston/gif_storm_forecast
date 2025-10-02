# GIF Storm Forecast - Terraform Infrastructure

This directory contains Terraform configuration to deploy the GIF Storm Forecast application as a cost-effective static website on AWS using S3 and optional CloudFront CDN.

## Overview

The infrastructure creates:
- **S3 Bucket**: Static website hosting for the application and GIF assets
- **S3 Bucket Policy**: Public read access for website content
- **CloudFront Distribution** (Optional): CDN for improved performance and HTTPS support

## Prerequisites

### Required Software
- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0 (configured with credentials)

### AWS Account Requirements
- Active AWS account with billing enabled
- AWS CLI configured with appropriate credentials
- Required AWS permissions (see [IAM Permissions](#iam-permissions) section)

### Cost Considerations
- **S3 Only**: ~$0.50-2.00/month (depending on traffic and storage)
- **S3 + CloudFront**: ~$1.00-5.00/month (additional CDN costs)
- See [Cost Optimization](#cost-optimization) section for detailed breakdown

## Quick Start

### 1. Configure Variables
```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your preferred settings
nano terraform.tfvars
```

### 2. Deploy Infrastructure
```bash
# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Deploy infrastructure
terraform apply
```

### 3. Upload Website Content
```bash
# Get bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload website files from project root
cd ..
aws s3 sync . s3://$BUCKET_NAME/ \
  --exclude "*.md" \
  --exclude "deploy/*" \
  --exclude ".git/*" \
  --exclude "terraform/*"
```

### 4. Access Your Website
```bash
# Get website URL
terraform output s3_website_url

# If CloudFront is enabled
terraform output cloudfront_url
```

## Configuration Options

### Basic Configuration (terraform.tfvars)
```hcl
# Minimal setup for development
aws_region = "us-east-1"
environment = "dev"
project_name = "gif-storm-forecast"
enable_cloudfront = false
```

### Production Configuration
```hcl
# Production setup with CDN
aws_region = "us-east-1"
environment = "prod"
project_name = "gif-storm-forecast"
enable_cloudfront = true
bucket_name = "my-company-gif-storm-prod"
```

## Deployment Scenarios

### Scenario 1: Development/Testing (Minimal Cost)
**Use Case**: Local development, testing, proof of concept
**Configuration**:
```hcl
environment = "dev"
enable_cloudfront = false
```
**Expected Cost**: ~$0.50-1.00/month
**Deployment Time**: 2-3 minutes

### Scenario 2: Production (Performance Optimized)
**Use Case**: Public-facing deployment, kiosk displays
**Configuration**:
```hcl
environment = "prod"
enable_cloudfront = true
aws_region = "us-east-1"  # Closest to your users
```
**Expected Cost**: ~$2.00-5.00/month
**Deployment Time**: 15-20 minutes (CloudFront distribution)

### Scenario 3: Multi-Environment Setup
Deploy separate environments for development, staging, and production:

```bash
# Development
terraform workspace new dev
terraform apply -var="environment=dev" -var="enable_cloudfront=false"

# Staging
terraform workspace new staging  
terraform apply -var="environment=staging" -var="enable_cloudfront=true"

# Production
terraform workspace new prod
terraform apply -var="environment=prod" -var="enable_cloudfront=true"
```

## Variable Reference

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `bucket_name` | string | null | S3 bucket name (auto-generated if not provided) |
| `aws_region` | string | "us-east-1" | AWS region for deployment |
| `environment` | string | "dev" | Environment name for tagging |
| `project_name` | string | "gif-storm-forecast" | Project name for resource naming |
| `enable_cloudfront` | bool | false | Enable CloudFront CDN |

### Variable Validation Rules
- **bucket_name**: 3-63 characters, lowercase letters/numbers/hyphens only
- **aws_region**: Must be supported region for S3 static website hosting
- **environment**: Lowercase letters, numbers, and hyphens only
- **project_name**: Lowercase letters, numbers, and hyphens only

## Outputs Reference

After successful deployment, Terraform provides these outputs:

| Output | Description | Example |
|--------|-------------|---------|
| `s3_bucket_name` | Created S3 bucket name | `gif-storm-forecast-dev-a1b2c3d4` |
| `s3_website_endpoint` | S3 website endpoint | `bucket.s3-website-us-east-1.amazonaws.com` |
| `s3_website_url` | Complete S3 website URL | `http://bucket.s3-website-us-east-1.amazonaws.com` |
| `cloudfront_distribution_id` | CloudFront distribution ID | `E1234567890ABC` |
| `cloudfront_domain_name` | CloudFront domain name | `d1234567890abc.cloudfront.net` |
| `cloudfront_url` | Complete CloudFront URL | `https://d1234567890abc.cloudfront.net` |
| `deployment_instructions` | Step-by-step upload instructions | Multi-line deployment guide |

## IAM Permissions

### Minimum Required Permissions
Your AWS credentials need these permissions:

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
        "s3:GetBucketWebsite",
        "s3:ListBucket",
        "s3:PutBucketPolicy",
        "s3:PutBucketWebsite",
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
    }
  ]
}
```

### Additional Permissions for CloudFront
If using CloudFront (`enable_cloudfront = true`):

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
    "cloudfront:UntagResource"
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
- Verify bucket policy allows public read access
- Check S3 public access block settings
- Ensure files are uploaded to bucket
- Wait for DNS propagation (up to 24 hours)

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

#### 1. Terraform Configuration Validation
```bash
# Validate syntax and configuration
terraform validate

# Expected output:
# Success! The configuration is valid.
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
# Valid S3-only configuration
terraform plan \
  -var="aws_region=us-east-1" \
  -var="environment=dev" \
  -var="project_name=gif-storm-forecast" \
  -var="enable_cloudfront=false"

# Valid CloudFront configuration
terraform plan \
  -var="aws_region=us-west-2" \
  -var="environment=prod" \
  -var="project_name=my-gif-app" \
  -var="enable_cloudfront=true" \
  -var="bucket_name=my-unique-gif-bucket-2024"
```

### Deployment Testing

#### Test Scenario 1: S3-Only Deployment
**Purpose**: Validate minimal cost deployment for development/testing

```bash
# 1. Create test configuration
cat > test-s3-only.tfvars << EOF
aws_region = "us-east-1"
environment = "test"
project_name = "gif-storm-test"
enable_cloudfront = false
EOF

# 2. Plan deployment
terraform plan -var-file="test-s3-only.tfvars"

# 3. Expected resources in plan:
# - aws_s3_bucket.website
# - aws_s3_bucket_website_configuration.website
# - aws_s3_bucket_public_access_block.website
# - aws_s3_bucket_policy.website
# - random_id.bucket_suffix

# 4. Deploy (optional - will create real resources)
terraform apply -var-file="test-s3-only.tfvars" -auto-approve

# 5. Validate outputs
terraform output s3_bucket_name
terraform output s3_website_url
# CloudFront outputs should be null
terraform output cloudfront_url

# 6. Test website accessibility
curl -I $(terraform output -raw s3_website_url)
# Expected: HTTP 404 (bucket exists but no content uploaded)

# 7. Cleanup
terraform destroy -var-file="test-s3-only.tfvars" -auto-approve
```

#### Test Scenario 2: CloudFront Deployment
**Purpose**: Validate full-featured deployment with CDN

```bash
# 1. Create test configuration
cat > test-cloudfront.tfvars << EOF
aws_region = "us-west-2"
environment = "staging"
project_name = "gif-storm-staging"
enable_cloudfront = true
bucket_name = "gif-storm-test-$(date +%s)"
EOF

# 2. Plan deployment
terraform plan -var-file="test-cloudfront.tfvars"

# 3. Expected resources in plan:
# - All S3 resources from Scenario 1
# - aws_cloudfront_distribution.website[0]

# 4. Deploy (optional - takes 15-20 minutes)
terraform apply -var-file="test-cloudfront.tfvars" -auto-approve

# 5. Validate outputs
terraform output s3_bucket_name
terraform output s3_website_url
terraform output cloudfront_distribution_id
terraform output cloudfront_domain_name
terraform output cloudfront_url

# 6. Test both endpoints
curl -I $(terraform output -raw s3_website_url)
curl -I $(terraform output -raw cloudfront_url)

# 7. Cleanup
terraform destroy -var-file="test-cloudfront.tfvars" -auto-approve
```

#### Test Scenario 3: Multi-Environment Deployment
**Purpose**: Validate workspace-based multi-environment setup

```bash
# 1. Test development environment
terraform workspace new dev-test
terraform plan \
  -var="environment=dev" \
  -var="enable_cloudfront=false"

# 2. Test production environment  
terraform workspace new prod-test
terraform plan \
  -var="environment=prod" \
  -var="enable_cloudfront=true"

# 3. Validate workspace isolation
terraform workspace select dev-test
terraform output  # Should show dev outputs or empty

terraform workspace select prod-test  
terraform output  # Should show prod outputs or empty

# 4. Cleanup workspaces
terraform workspace select default
terraform workspace delete dev-test
terraform workspace delete prod-test
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

# Test invalid bucket names
echo "Testing invalid bucket names..."
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

# S3-only configuration
terraform plan \
  -var="aws_region=us-east-1" \
  -var="environment=dev" \
  -var="project_name=test-project" \
  -var="enable_cloudfront=false" \
  -out=s3-only.tfplan

echo "✓ S3-only configuration is valid"

# CloudFront configuration
terraform plan \
  -var="aws_region=us-west-2" \
  -var="environment=prod" \
  -var="project_name=test-project" \
  -var="enable_cloudfront=true" \
  -out=cloudfront.tfplan

echo "✓ CloudFront configuration is valid"

# Test 4: Resource count validation
echo "Validating expected resource counts..."

# Check S3-only plan
s3_resources=$(terraform show -json s3-only.tfplan | jq '.planned_values.root_module.resources | length')
if [ "$s3_resources" -eq 5 ]; then
  echo "✓ S3-only plan has correct resource count (5)"
else
  echo "✗ S3-only plan has $s3_resources resources, expected 5"
fi

# Check CloudFront plan
cf_resources=$(terraform show -json cloudfront.tfplan | jq '.planned_values.root_module.resources | length')
if [ "$cf_resources" -eq 6 ]; then
  echo "✓ CloudFront plan has correct resource count (6)"
else
  echo "✗ CloudFront plan has $cf_resources resources, expected 6"
fi

# Cleanup
rm -f s3-only.tfplan cloudfront.tfplan

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
# e2e-test.sh - Complete deployment and functionality test

set -e

PROJECT_NAME="gif-storm-e2e-test"
ENVIRONMENT="test"
TIMESTAMP=$(date +%s)

echo "=== Starting End-to-End Test ==="

# 1. Deploy infrastructure
echo "Deploying test infrastructure..."
terraform apply -auto-approve \
  -var="project_name=${PROJECT_NAME}" \
  -var="environment=${ENVIRONMENT}" \
  -var="enable_cloudfront=false"

# 2. Get outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
WEBSITE_URL=$(terraform output -raw s3_website_url)

echo "Deployed to bucket: $BUCKET_NAME"
echo "Website URL: $WEBSITE_URL"

# 3. Upload test content
echo "Uploading test content..."
cd ..
aws s3 sync . s3://$BUCKET_NAME/ \
  --exclude "*.md" \
  --exclude "deploy/*" \
  --exclude ".git/*" \
  --exclude "terraform/*"

# 4. Test website accessibility
echo "Testing website accessibility..."
sleep 10  # Wait for S3 to propagate

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $WEBSITE_URL)
if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "✓ Website is accessible (HTTP $HTTP_STATUS)"
else
  echo "✗ Website returned HTTP $HTTP_STATUS"
fi

# 5. Test specific files
echo "Testing GIF file access..."
GIF_URL="${WEBSITE_URL}/sample_gifs/3.gif"
GIF_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $GIF_URL)
if [ "$GIF_STATUS" -eq 200 ]; then
  echo "✓ GIF files are accessible (HTTP $GIF_STATUS)"
else
  echo "✗ GIF file returned HTTP $GIF_STATUS"
fi

# 6. Cleanup
echo "Cleaning up test resources..."
cd terraform
terraform destroy -auto-approve \
  -var="project_name=${PROJECT_NAME}" \
  -var="environment=${ENVIRONMENT}" \
  -var="enable_cloudfront=false"

echo "=== End-to-End Test Complete ==="
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
  "$WEBSITE_URL/sample_gifs/3.gif"
  "$WEBSITE_URL/sample_gifs/4.gif"
  "$WEBSITE_URL/sample_gifs/5.gif"
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
        
    - name: Terraform Plan (S3 Only)
      run: |
        cd terraform
        terraform plan \
          -var="environment=ci-test" \
          -var="enable_cloudfront=false"
          
    - name: Terraform Plan (CloudFront)
      run: |
        cd terraform
        terraform plan \
          -var="environment=ci-test" \
          -var="enable_cloudfront=true"

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
- [ ] S3-only configuration plan reviewed
- [ ] CloudFront configuration plan reviewed
- [ ] Expected resource count verified
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

#### S3-Only Configuration (Recommended for Most Use Cases)
**Estimated Cost: $0.50 - $2.00/month**

| Component | Usage | Cost |
|-----------|-------|------|
| S3 Standard Storage | 100MB website + GIFs | $0.02/month |
| S3 Requests (GET) | 10,000 requests/month | $0.04/month |
| Data Transfer Out | 1GB/month | $0.09/month |
| **Total** | | **~$0.15/month** |

*Note: Costs scale with traffic. High-traffic sites may reach $1-2/month.*

#### S3 + CloudFront Configuration
**Estimated Cost: $1.00 - $5.00/month**

| Component | Usage | Cost |
|-----------|-------|------|
| S3 Standard Storage | 100MB website + GIFs | $0.02/month |
| S3 Requests (reduced) | 1,000 requests/month | $0.004/month |
| CloudFront Requests | 10,000 requests/month | $0.10/month |
| CloudFront Data Transfer | 1GB/month | $0.085/month |
| **Total** | | **~$0.21/month** |

*Note: CloudFront reduces S3 costs but adds CDN costs. Break-even at ~5GB/month traffic.*

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

#### 4. Traffic-Based Recommendations

**Low Traffic (< 1GB/month)**:
- Use S3-only configuration
- Skip CloudFront to avoid minimum charges
- Expected cost: $0.15-0.50/month

**Medium Traffic (1-10GB/month)**:
- Consider CloudFront for performance
- Monitor costs monthly
- Expected cost: $0.50-2.00/month

**High Traffic (> 10GB/month)**:
- Use CloudFront for cost savings
- Consider S3 Transfer Acceleration
- Expected cost: $2.00-10.00/month

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

#### 1. Minimize S3 Requests
```bash
# Upload with optimized sync (reduces PUT requests)
aws s3 sync . s3://bucket-name/ \
  --delete \
  --exclude "*.md" \
  --exclude "deploy/*" \
  --exclude ".git/*" \
  --exclude "terraform/*"
```

#### 2. Optimize GIF Files
Before uploading, optimize GIF files:
```bash
# Install gifsicle for GIF optimization
brew install gifsicle  # macOS
apt-get install gifsicle  # Ubuntu

# Optimize GIFs (reduces storage and transfer costs)
find sample_gifs/ -name "*.gif" -exec gifsicle --optimize=3 --output={} {} \;
```

#### 3. Enable S3 Intelligent Tiering (Optional)
For mixed access patterns:
```hcl
resource "aws_s3_bucket_intelligent_tiering_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  name   = "EntireBucket"

  status = "Enabled"
}
```

#### 4. CloudFront Cache Optimization
Maximize cache hit ratio:
```hcl
# Optimize for static content
default_cache_behavior {
  # Cache GIFs for 7 days
  default_ttl = 604800  # 7 days
  max_ttl     = 2592000 # 30 days
  
  # Cache HTML for 1 hour
  min_ttl = 0
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