# Product Overview

GIF Storm Forecast is a full-screen kiosk-style GIF slideshow application designed for digital displays and ambient screens, with enterprise-ready Infrastructure-as-Code deployment.

## Core Functionality
- Displays animated GIFs in continuous full-screen slideshow
- Each GIF plays 3 complete animation cycles before advancing
- Supports both local development mode and S3-hosted production
- Automatic cursor hiding for kiosk environments
- Infinite loop through all available GIFs

## Target Use Cases
- Digital kiosks and public displays
- Ambient office screens
- Art installations
- Waiting room displays
- Corporate lobbies and reception areas
- Event displays and digital signage

## Deployment Options

### Infrastructure-as-Code (Primary)
- **Terraform-managed**: Automated, repeatable deployments
- **Cost-optimized**: S3-only (~$0.50-2.00/month) or S3+CloudFront configurations
- **Multi-environment**: Support for dev/staging/prod environments
- **Enterprise-ready**: Comprehensive validation, testing, and monitoring

### Manual Deployment (Legacy)
- **AWS CLI**: Simple deployment for learning or one-off use cases
- **Quick setup**: Direct S3 bucket configuration
- **Limited features**: Basic hosting without advanced optimization

## Key Design Principles
- **Minimal UI**: Maximum visual impact with zero interface elements
- **Zero-maintenance**: Automated operation once deployed
- **Lightweight**: Pure static web application with no server requirements
- **Responsive**: Full-screen display across all device sizes
- **Cost-effective**: Optimized for minimal AWS costs while maintaining performance
- **Scalable**: Infrastructure that grows with usage demands
- **Reliable**: Enterprise-grade deployment with proper resource management