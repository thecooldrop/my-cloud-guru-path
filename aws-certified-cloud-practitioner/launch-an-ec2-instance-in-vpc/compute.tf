data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "ED25519"
}

resource "local_file" "private_key_file" {
  filename = "key.pem"
  content  = tls_private_key.private_key.private_key_openssh
  file_permission = "600"
}

resource "aws_key_pair" "instance_key_pair" {
  public_key = tls_private_key.private_key.public_key_openssh
  key_name = "instance_key_pair"
}

resource "aws_instance" "instance" {
  ami = data.aws_ami.amzn-linux-2023-ami.id
  associate_public_ip_address = true
  instance_type = "t3.micro"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [
    aws_security_group.security_group.id
  ]
  key_name = aws_key_pair.instance_key_pair.key_name
}

resource "aws_security_group" "security_group" {
  name = "instance_security_group"
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_anywhere" {
  security_group_id = aws_security_group.security_group.id
  ip_protocol = "TCP"
  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
}

output "ip" {
  value = aws_instance.instance.public_ip
}
