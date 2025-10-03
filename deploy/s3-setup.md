# Deployment Setup

⚠️ **DEPRECATED**: This manual deployment method is deprecated. Use Terraform for secure HTTPS deployment.

## Recommended: Terraform Deployment

For secure HTTPS deployment with CloudFront and private S3 bucket:

```bash
# 1. Deploy infrastructure with Terraform
cd terraform
terraform init
terraform apply

# 2. Upload content to private S3 bucket
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
cd ../web_app
aws s3 sync . s3://$BUCKET_NAME/

# 3. Access your secure HTTPS website
cd ../terraform
terraform output website_url
```

## Legacy Manual Setup (Not Recommended)

⚠️ **Security Warning**: This method creates a public S3 bucket which is not secure.

### Prerequisites
- AWS CLI installed and configured
- Appropriate AWS permissions for S3 and CloudFront

### Steps for CloudFront + Private S3

1. **Create private S3 bucket**:
   ```bash
   aws s3 mb s3://your-gif-slideshow-bucket
   # Note: Do NOT enable public access or website hosting
   ```

2. **Upload content to private bucket**:
   ```bash
   aws s3 sync ../web_app s3://your-gif-slideshow-bucket/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*" --exclude "terraform/*" --exclude ".kiro/*"
   ```

3. **Create CloudFront distribution manually** (complex - use Terraform instead):
   - Configure Origin Access Control (OAC)
   - Set up HTTPS-only viewer protocol policy
   - Configure S3 bucket policy for OAC access only

## Configuration
Update `js/config.js` with your CloudFront distribution URL (HTTPS only).