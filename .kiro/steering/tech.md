# Technology Stack

## Core Technologies
- **Frontend**: Vanilla JavaScript (ES6+), HTML5, CSS3
- **Hosting**: AWS CloudFront with HTTPS-only delivery
- **CDN**: AWS CloudFront (mandatory for security)
- **Storage**: Private AWS S3 bucket with Origin Access Control
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
- `gifs/` - Local development assets
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

# Secure HTTPS deployment (mandatory)
cd terraform
terraform init
terraform apply
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ../web_app && aws s3 sync . s3://$BUCKET_NAME/

# Legacy manual deployment (deprecated - use Terraform instead)
# Note: Manual deployment requires complex CloudFront and OAC setup
```

## Infrastructure Management
- **Terraform**: Primary deployment method with security and cost optimization
- **Multi-environment**: Support for dev/staging/prod environments
- **Secure HTTPS**: Mandatory CloudFront with private S3 (~$1-3/month)
- **Validation**: Comprehensive variable validation and testing framework

## Configuration Management
- Toggle between development/production via `CONFIG.DEVELOPMENT_MODE`
- All timing and behavior controlled through `CONFIG` object
- CloudFront HTTPS URL configurable for different environments
- Terraform variables for infrastructure customization

NEVER write shell scripts to apply terraform.
Instead, provide documentation on how to run terraform commands.