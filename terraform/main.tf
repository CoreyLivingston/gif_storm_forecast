# Generate random suffix for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Local values for consistent naming
locals {
  bucket_name = var.bucket_name != null ? var.bucket_name : "${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
}

# S3 bucket for private content storage
resource "aws_s3_bucket" "website" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "static-website-hosting"
  }
}

# S3 bucket website configuration removed - bucket is private and accessed via CloudFront OAC only

# S3 bucket public access block configuration - maximum security
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control for secure S3 access
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "Origin Access Control for ${var.project_name} S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 bucket policy for CloudFront OAC access only
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_cloudfront_distribution.website]
}

# CloudFront distribution (mandatory for secure architecture)
resource "aws_cloudfront_distribution" "website" {

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.website.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.website.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Optimized caching for static content like GIFs
    min_ttl     = 0
    default_ttl = 86400    # 24 hours
    max_ttl     = 31536000 # 1 year
  }

  # Specific cache behavior for GIF files - no caching for frequent updates
  ordered_cache_behavior {
    path_pattern           = "*.gif"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.website.id}"
    compress               = false # Don't compress GIFs (already compressed)
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true # Allow cache-busting query parameters
      cookies {
        forward = "none"
      }
    }

    # No caching for GIF files that change frequently
    min_ttl     = 0 # No minimum cache
    default_ttl = 0 # No default cache - always fetch from origin
    max_ttl     = 0 # No maximum cache
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}