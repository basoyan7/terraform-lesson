output "instance_ip_addr" {
  value = aws_instance.web.public_ip
}

output "my_random_string" {
  value = random_string.random.result
}