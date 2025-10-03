# GIF Storm Forecast

A full-screen kiosk-style GIF slideshow application that displays animated GIFs in a continuous loop.

## Overview

This project creates a static web application that displays GIFs from an S3 bucket in full-screen mode. Each GIF plays through 3 complete cycles before automatically advancing to the next one, creating an engaging slideshow experience perfect for digital displays, kiosks, or ambient screens.

## Features

- **Full-screen display**: GIFs are displayed in full-screen mode for maximum visual impact
- **Automatic progression**: Each GIF plays 3 complete loops before moving to the next
- **Secure HTTPS delivery**: All content served through CloudFront with mandatory HTTPS
- **Private S3 storage**: GIFs stored securely in private S3 bucket with Origin Access Control
- **Static web app**: Lightweight, client-side application with no server requirements
- **Continuous loop**: Slideshow runs indefinitely, cycling through all available GIFs
- **Global CDN**: Fast loading worldwide through CloudFront edge locations

## How it works

1. GIFs are uploaded to a configured S3 bucket
2. The web application fetches the list of available GIFs
3. Each GIF is displayed in full-screen mode
4. After 3 complete animation cycles, the app automatically advances to the next GIF
5. The slideshow continues indefinitely, looping back to the first GIF after the last one

## Quick Deployment

### Secure HTTPS Deployment

The application is deployed with mandatory HTTPS through CloudFront CDN for security and performance:

```bash
# 1. Configure Terraform (optional customization)
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars to customize bucket name, region, or environment

# 2. Deploy secure infrastructure
terraform init
terraform apply

# 3. Upload your GIFs and website files
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ../web_app
aws s3 sync . s3://$BUCKET_NAME/

# 4. Access your secure HTTPS website
cd ../terraform
terraform output website_url
```

### Security Benefits

- **HTTPS-Only Access**: All content is served securely through CloudFront with automatic HTTP to HTTPS redirection
- **Private S3 Storage**: Content is stored in a private S3 bucket with no public access
- **Origin Access Control**: CloudFront uses AWS's latest security model to access S3 content
- **Cost-Optimized**: Efficient CloudFront configuration keeps costs minimal (~$1-3/month)

## Performance & Security

The application is optimized for performance and security:

1. **HTTPS Delivery**: All content is automatically served over HTTPS through CloudFront
2. **Global CDN**: CloudFront edge locations provide fast loading worldwide
3. **Secure Storage**: Private S3 bucket prevents unauthorized access to your content
4. **Optimized Caching**: CloudFront caching reduces load times and bandwidth costs

### Troubleshooting

If you're experiencing issues:

1. **Check your config**: Ensure `DEVELOPMENT_MODE = false` in `js/config.js` for production
2. **Optimize GIFs**: Keep GIF files under 10MB for better performance
3. **CloudFront Propagation**: Allow 15-20 minutes for CloudFront deployment to complete

📖 **For detailed setup and troubleshooting, see [terraform/README.md](terraform/README.md)**
