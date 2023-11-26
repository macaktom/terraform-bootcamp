# Terraform web hosting CloudFront
Static website hosting using CloudFront + S3 bucket


Steps:
1. Setup networking (submodule) - 1 VPC + 1 subnet
1. Setup storage (submodule) with two S3 buckets -> primary and failover -> only accesible to users through CloudFront
2. Upload website on primary bucket and sync between them
3. Setup CloudFront distribution with 2 origins
4. Configure both origins
5. Create bucket policies for CloudFront to access S3 buckets
6. Create test for infrastructure
7. Test locally
8. Setup Jenkins + AWS config and add Jenkinsfile, which will apply terraform code
