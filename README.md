# Terraform web hosting CloudFront
Static website hosting using CloudFront + S3 bucket


Steps:
1. Setup two S3 buckets -> primary and failover
2. Upload website on primary bucket and sync between them
3. Setup CloudFront distribution with 2 origins
4. Configure both origins
5. Create bucket policies for CloudFront to access S3 buckets
6. Test locally
7. Setup Jenkins + AWS config and add Jenkinsfile, which will apply terraform code
