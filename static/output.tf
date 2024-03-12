output "bucket_name" {
  value = aws_s3_bucket.www_bucket.bucket_domain_name
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.www_bucket.website_endpoint
}

output "bucket_name_apex" {
  value = aws_s3_bucket.apex_bucket.bucket_domain_name
}

output "website_endpoint_apex" {
  value = aws_s3_bucket_website_configuration.apex_bucket.website_endpoint
}
