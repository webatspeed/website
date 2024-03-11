output "bucket_name" {
  value = aws_s3_bucket.www_bucket.bucket_domain_name
}
