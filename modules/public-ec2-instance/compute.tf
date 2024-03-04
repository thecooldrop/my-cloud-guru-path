data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_pattern_filter]
  }
}

resource "tls_private_key" "private_key" {
  algorithm = var.private_key_algorithm
}

resource "local_file" "private_key_file" {
  filename = var.private_key_file_path
  content  = tls_private_key.private_key.private_key_openssh
  file_permission = var.private_key_file_permissions
}

resource "aws_key_pair" "instance_key_pair" {
  public_key = tls_private_key.private_key.public_key_openssh
  key_name = var.key_pair_name
}

resource "aws_instance" "instance" {
  ami = data.aws_ami.amzn-linux-2023-ami.id
  associate_public_ip_address = true
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.security_group.id
  ]
  key_name = aws_key_pair.instance_key_pair.key_name
}

resource "aws_security_group" "security_group" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_anywhere" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol = "TCP"
  cidr_ipv4 = var.allowed_instance_ssh_traffic_cidr
  from_port = 22
  to_port = 22
}

output "ip" {
  value = aws_instance.instance.public_ip
}
