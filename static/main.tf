provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

resource "aws_s3_bucket" "www_bucket" {
  bucket = var.www_domain_name
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket = aws_s3_bucket.www_bucket.id
}

resource "aws_s3_bucket_website_configuration" "www_bucket" {
  bucket = aws_s3_bucket.www_bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket" "apex_bucket" {
  bucket = var.root_domain_name
}

resource "aws_s3_bucket_public_access_block" "apex_access_block" {
  bucket = aws_s3_bucket.apex_bucket.id
}

resource "aws_s3_bucket_website_configuration" "apex_bucket" {
  bucket = aws_s3_bucket.apex_bucket.id

  redirect_all_requests_to {
    host_name = var.www_domain_name
    protocol  = "https"
  }
}

resource "aws_s3_bucket" "legacy_bucket" {
  bucket = var.legacy_domain_name
}

resource "aws_s3_bucket_public_access_block" "legacy_access_block" {
  bucket = aws_s3_bucket.legacy_bucket.id
}

resource "aws_s3_bucket_website_configuration" "legacy_bucket" {
  bucket = aws_s3_bucket.legacy_bucket.id

  index_document {
    suffix = "index.html"
  }
}

data "aws_iam_policy_document" "webatspeed_iam_static_s3_policy_document" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:GetObject",
    ]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    resources = [
      aws_s3_bucket.www_bucket.arn,
      "${aws_s3_bucket.www_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "webatspeed_iam_static_s3_policy_document_apex" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:GetObject",
    ]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    resources = [
      aws_s3_bucket.apex_bucket.arn,
      "${aws_s3_bucket.apex_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "webatspeed_iam_static_s3_policy_document_legacy" {
  version = "2012-10-17"
  statement {
    actions = [
      "s3:GetObject",
    ]
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    resources = [
      aws_s3_bucket.legacy_bucket.arn,
      "${aws_s3_bucket.legacy_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.www_bucket.id
  policy = data.aws_iam_policy_document.webatspeed_iam_static_s3_policy_document.json
}

resource "aws_s3_bucket_policy" "apex_policy" {
  bucket = aws_s3_bucket.apex_bucket.id
  policy = data.aws_iam_policy_document.webatspeed_iam_static_s3_policy_document_apex.json
}

resource "aws_s3_bucket_policy" "legacy_policy" {
  bucket = aws_s3_bucket.legacy_bucket.id
  policy = data.aws_iam_policy_document.webatspeed_iam_static_s3_policy_document_legacy.json
}
