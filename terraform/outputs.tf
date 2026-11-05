output "ec2_public_ip" {
  value = aws_instance.app.public_ip
}

output "ecr_urls" {
  value = { for k, r in aws_ecr_repository.svc : k => r.repository_url }
}
