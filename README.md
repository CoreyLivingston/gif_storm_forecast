# GIF Storm Forecast

A full-screen kiosk-style GIF slideshow application that displays animated GIFs in a continuous loop.

## Overview

This project creates a static web application that displays GIFs from an S3 bucket in full-screen mode. Each GIF plays through 3 complete cycles before automatically advancing to the next one, creating an engaging slideshow experience perfect for digital displays, kiosks, or ambient screens.

## Features

- **Full-screen display**: GIFs are displayed in full-screen mode for maximum visual impact
- **Automatic progression**: Each GIF plays 3 complete loops before moving to the next
- **S3 integration**: GIFs are stored and served from an AWS S3 bucket
- **Static web app**: Lightweight, client-side application with no server requirements
- **Continuous loop**: Slideshow runs indefinitely, cycling through all available GIFs

## How it works

1. GIFs are uploaded to a configured S3 bucket
2. The web application fetches the list of available GIFs
3. Each GIF is displayed in full-screen mode
4. After 3 complete animation cycles, the app automatically advances to the next GIF
5. The slideshow continues indefinitely, looping back to the first GIF after the last one

## Deployment Options

### Option 1: Terraform Infrastructure (Recommended)

Deploy the application using Infrastructure-as-Code with Terraform for automated, consistent deployments.

**Quick Start:**
```bash
# Navigate to terraform directory
cd terraform

# Configure your deployment
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred settings

# Deploy infrastructure
terraform init
terraform apply

# Upload website content
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ..
aws s3 sync . s3://$BUCKET_NAME/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*" --exclude "terraform/*"

# Get your website URL
cd terraform
terraform output s3_website_url
```

**Benefits:**
- Automated infrastructure provisioning with repeatable deployments
- Cost-optimized configuration (~$0.50-2.00/month for S3-only)
- Optional CloudFront CDN for improved performance and HTTPS
- Multi-environment support (dev/staging/prod)
- Easy cleanup with `terraform destroy`

**Configuration Options:**
- **Development**: S3-only hosting for minimal cost
- **Production**: S3 + CloudFront for performance optimization
- **Custom**: Configurable regions, naming, and features

📖 **For complete setup instructions, configuration options, and troubleshooting, see the [Terraform README](terraform/README.md).**

### Option 2: Manual AWS CLI Deployment

For simple deployments or learning purposes, you can deploy manually using the AWS CLI.

**Prerequisites:**
- AWS CLI installed and configured
- S3 bucket created for static website hosting

**Deployment Steps:**
```bash
# Upload files to your S3 bucket
aws s3 sync . s3://your-bucket-name/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*"

# Configure bucket for static website hosting
aws s3 website s3://your-bucket-name --index-document index.html --error-document index.html
```

For detailed manual deployment instructions, see [deploy/s3-setup.md](deploy/s3-setup.md).
