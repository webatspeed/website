output "project_id_frontend" {
  value = aws_codebuild_project.webatspeed_build_frontend.id
}

output "project_id_subscription" {
  value = aws_codebuild_project.webatspeed_build_subscription.id
}
