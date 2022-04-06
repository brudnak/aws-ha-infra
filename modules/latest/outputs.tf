output "instance_public_ip" {
  value = [for instance in aws_instance.aws_instance : instance.public_ip]
}
output "instance_private_ip" {
  value = [for instance in aws_instance.aws_instance : instance.private_ip]
}

output "random_pet_id_for_latest" {
  value = random_pet.random_pet.id
}

output "latest_load_balancer_dns_name" {
  value = aws_lb.aws_lb.dns_name
}
