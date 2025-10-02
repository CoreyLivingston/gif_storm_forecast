# Technology Stack

## Core Technologies
- **Frontend**: Vanilla JavaScript (ES6+), HTML5, CSS3
- **Hosting**: AWS S3 static website hosting
- **CDN**: AWS CloudFront (optional)
- **Storage**: AWS S3 for GIF assets
- **Infrastructure**: Terraform for Infrastructure-as-Code
- **Development**: Local file system with sample GIFs, Devbox for environment management

## Architecture
- Pure client-side static web application
- No build system or bundling required
- No external dependencies or frameworks
- Configuration-driven development/production modes
- Infrastructure-as-Code with Terraform for repeatable deployments

## File Structure
- `index.html` - Single page application entry point
- `js/config.js` - Environment and behavior configuration
- `js/slideshow.js` - Core slideshow logic as ES6 class
- `css/styles.css` - Full-screen styling and responsive design
- `sample_gifs/` - Local development assets
- `deploy/` - Manual AWS deployment scripts and policies
- `terraform/` - Infrastructure-as-Code configuration
- `devbox.json` - Development environment configuration

## Development Environment
- **Devbox**: Reproducible development environment with Terraform and AWS CLI
- **Environment Variables**: Pre-configured AWS profile and Terraform variables
- **Local Development**: HTTP server for testing static files

## Development Commands
```bash
# Local development - serve files with any HTTP server
python3 -m http.server 8000
# or
npx serve .

# Terraform deployment (recommended)
cd terraform
terraform init
terraform apply
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd .. && aws s3 sync . s3://$BUCKET_NAME/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*" --exclude "terraform/*"

# Manual S3 deployment (legacy)
 aws s3 sync . s3://gif-storm-forecast-dev-59155a9e/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*" --exclude "terraform/*" --exclude ".kiro/*" --exclude "devbox.json" --exclude "devbox.lock" --exclude ".devbox/*"
```

## Infrastructure Management
- **Terraform**: Primary deployment method with cost optimization
- **Multi-environment**: Support for dev/staging/prod environments
- **Cost-optimized**: S3-only (~$0.50-2.00/month) or S3+CloudFront configurations
- **Validation**: Comprehensive variable validation and testing framework

## Configuration Management
- Toggle between development/production via `CONFIG.DEVELOPMENT_MODE`
- All timing and behavior controlled through `CONFIG` object
- S3 bucket URL configurable for different environments
- Terraform variables for infrastructure customization