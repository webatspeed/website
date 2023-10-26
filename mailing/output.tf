output "smtp_username" {
  value = aws_iam_access_key.webatspeed_iam_access_key.id
}

output "smtp_password" {
  value = aws_iam_access_key.webatspeed_iam_access_key.secret
}

output "bucket_name" {
  value = aws_s3_bucket.webatspeed_s3_bucket_attachments.bucket
}
