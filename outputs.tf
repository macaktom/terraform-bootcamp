output "bucket_name" {
    description = "Bucket name for static website hosting"
    value = module.static_web_hosting.bucket_name
}

output "cloudfront_domain" {
    description = "CloudFront domain name"
    value = module.static_web_hosting.cloudfront_domain
}