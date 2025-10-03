# Primary website access - HTTPS-only via CloudFront
output "website_url" {
  description = "Primary HTTPS website URL via CloudFront"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

# S3 bucket for content upload reference (private bucket, no direct access)
output "s3_bucket_name" {
  description = "Name of the created S3 bucket for content uploads"
  value       = aws_s3_bucket.website.id
}

# CloudFront distribution details
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.website.domain_name
}

# Origin Access Control for secure CloudFront-S3 integration
output "origin_access_control_id" {
  description = "Origin Access Control ID for CloudFront-S3 integration"
  value       = aws_cloudfront_origin_access_control.website.id
}

output "deployment_instructions" {
  description = "Instructions for uploading website content to secure infrastructure"
  value = <<-EOT
    To deploy your website content to the secure infrastructure:
    
    1. Upload files to private S3 bucket: ${aws_s3_bucket.website.id}
       aws s3 sync . s3://${aws_s3_bucket.website.id}/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*" --exclude "terraform/*"
    
    2. Access your secure website at:
       HTTPS URL: https://${aws_cloudfront_distribution.website.domain_name}
       
    Note: The S3 bucket is private and only accessible through CloudFront with HTTPS.
  EOT
}