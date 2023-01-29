#output "instance_public_ip" {
#  value = [for instance in aws_instance.aws_instance : "public IP for rke config: ${instance.public_ip}"]
#}
#output "instance_private_ip" {
#  value = [for instance in aws_instance.aws_instance : "private IP for rke config: ${instance.private_ip}"]
#}

output "server1_ip" {
  value = aws_instance.aws_instance[0].public_ip
}

output "server2_ip" {
  value = aws_instance.aws_instance[1].public_ip
}

output "server3_ip" {
  value = aws_instance.aws_instance[2].public_ip
}

output "server1_private_ip" {
  value = aws_instance.aws_instance[0].private_ip
}

output "server2_private_ip" {
  value = aws_instance.aws_instance[1].private_ip
}

output "server3_private_ip" {
  value = aws_instance.aws_instance[2].private_ip
}

output "rancher_url" {
  value = aws_route53_record.aws_route53_record.fqdn
}
