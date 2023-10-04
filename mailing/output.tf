output "smtp_username" {
  value = aws_iam_access_key.webatspeed_iam_access_key.id
}

output "smtp_password" {
  value = aws_iam_access_key.webatspeed_iam_access_key.ses_smtp_password_v4
}
