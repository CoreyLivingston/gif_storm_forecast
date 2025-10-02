output "s3_bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.website.id
}

output "s3_website_endpoint" {
  description = "S3 website endpoint URL"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "s3_website_url" {
  description = "Complete S3 website URL (HTTP)"
  value       = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (only when CloudFront is enabled)"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name (only when CloudFront is enabled)"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "cloudfront_url" {
  description = "Complete CloudFront URL with HTTPS (only when CloudFront is enabled)"
  value       = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.website[0].domain_name}" : null
}

output "deployment_instructions" {
  description = "Instructions for uploading website content"
  value = <<-EOT
    To deploy your website content:
    
    1. Upload files to S3 bucket: ${aws_s3_bucket.website.id}
       aws s3 sync . s3://${aws_s3_bucket.website.id}/ --exclude "*.md" --exclude "deploy/*" --exclude ".git/*" --exclude "terraform/*"
    
    2. Access your website at:
       S3 Website URL: http://${aws_s3_bucket_website_configuration.website.website_endpoint}
       ${var.enable_cloudfront ? "CloudFront URL: https://${aws_cloudfront_distribution.website[0].domain_name}" : ""}
  EOT
}