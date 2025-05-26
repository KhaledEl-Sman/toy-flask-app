output "elastic_ip" {
  value = aws_eip.eip.public_ip
}

output "domain" {
  value = var.domain_name
}
