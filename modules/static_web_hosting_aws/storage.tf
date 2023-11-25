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


resource "aws_s3_bucket_policy" "allow_access_for_cloud_front" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.allow_access_for_cloud_front.json
}

data "aws_iam_policy_document" "allow_access_for_cloud_front" {
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
