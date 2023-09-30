# Create an S3 bucket for the website
resource "aws_s3_bucket" "website_bucket" {
  bucket = "terraform-static-hosting-bucket"

  tags = {
    UserUuid = var.user_uuid
  }
}

resource "aws_s3_bucket_website_configuration" "website_bucket_configuration" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "website_bucket_ownership" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "website_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.website_bucket_ownership]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "private"
}


resource "aws_s3_bucket_policy" "allow_access_from_cloud_front" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_cloud_front.json
}

data "aws_iam_policy_document" "allow_access_from_cloud_front" {
  statement {
    actions = [ "s3:GetObject" ]
    resources = [ "${aws_s3_bucket.website_bucket.arn}/*" ]
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.s3_distribution.arn]
    }
  }
}



resource "aws_s3_object" "website_index" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "index.html"
  source = "${path.root}/public/index.html"

  etag = filemd5("${path.root}/public/index.html")
  content_type = "text/html"
}


resource "aws_s3_object" "website_stylesx" {
  bucket = aws_s3_bucket.website_bucket.id
  key    = "style.css"
  source = "${path.root}/public/style.css"

  etag = filemd5("${path.root}/public/style.css")
  content_type = "text/css"
}



/*
resource "aws_s3_bucket_policy" "cloudfront_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:ListBucket",  
          "s3:GetObject"
        ],
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com",
        },
        Resource = aws_s3_bucket.website_bucket.arn,
      },
    ],
  })
}
*/


resource "aws_cloudfront_origin_access_control" "s3_origin_access" {
  name                              = "static-website-s3-origin-access"
  description                       = "CloudFront access for S3 origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}



resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin_access.id
    origin_id                = "S3Origin-static-website"
  }

  enabled             = true
  default_root_object = "index.html"
  comment = "Used for serving static website from S3 bucket. Caching is allowed."


  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin-static-website"

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Environment = "dev"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

}