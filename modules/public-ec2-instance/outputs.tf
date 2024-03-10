output "instance_id" {
  value = aws_instance.instance.id
}

output "public_instance_ip" {
  value = aws_instance.instance.public_ip
}