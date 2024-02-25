terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
  }
}

locals {
  disable-traffic = true
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "HoLVPC" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "hol-public-a" {
  vpc_id                  = aws_vpc.HoLVPC.id
  availability_zone       = "eu-central-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "hol-private-b" {
  vpc_id            = aws_vpc.HoLVPC.id
  availability_zone = "eu-central-1b"
  cidr_block        = "10.0.2.0/24"
}

resource "aws_internet_gateway" "hol-VPCIGW" {
  tags = {
    Name = "hol-VPCIGW"
  }
}

resource "aws_internet_gateway_attachment" "hol-VPCIGW-attachment" {
  internet_gateway_id = aws_internet_gateway.hol-VPCIGW.id
  vpc_id              = aws_vpc.HoLVPC.id
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.HoLVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hol-VPCIGW.id
  }
}

resource "aws_route_table_association" "private-table-association" {
  subnet_id      = aws_subnet.hol-public-a.id
  route_table_id = aws_route_table.publicRT.id
}

data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "hol-pub-instance" {
  tags = {
    Name = "hol-pub-instance"
  }
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.hol-public-a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.holpubSG.id
  ]
  ami      = data.aws_ami.amzn-linux-2023-ami.id
  key_name = aws_key_pair.vpcpubhol.key_name
}

resource "aws_instance" "hol-priv-instance" {
  tags = {
    Name = "hol-priv-instance"
  }

  instance_type = "t3.micro"
  subnet_id     = aws_subnet.hol-private-b.id
  vpc_security_group_ids = [
    aws_security_group.holprivSG.id
  ]
  ami = data.aws_ami.amzn-linux-2023-ami.id
}

resource "aws_security_group" "holpubSG" {
  name   = "holpubSG"
  vpc_id = aws_vpc.HoLVPC.id
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh-ingress-rule-public-sg" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.holpubSG.id
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = aws_vpc.HoLVPC.cidr_block
}

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

resource "aws_vpc_security_group_ingress_rule" "allow-from-my-ip-private-sg" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.holpubSG.id
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "${chomp(data.http.myip.response_body)}/32"
}



resource "aws_security_group" "holprivSG" {
  name   = "holprivSG"
  vpc_id = aws_vpc.HoLVPC.id
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh-ingress-rule-private-sg" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.holprivSG.id
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = aws_vpc.HoLVPC.cidr_block
}


# ED25519 key
resource "tls_private_key" "ed25519-example" {
  algorithm = "ED25519"
}


resource "aws_key_pair" "vpcpubhol" {
  key_name   = "vpcpubhol"
  public_key = tls_private_key.ed25519-example.public_key_openssh
}

resource "local_file" "private-key-pem" {
  filename = "key.pem"
  content  = tls_private_key.ed25519-example.private_key_pem
}

output "ec2-public-ip" {
  value = aws_instance.hol-pub-instance.public_ip
}

resource "aws_network_acl_rule" "deny-traffic" {
  count          = local.disable-traffic ? 1 : 0
  rule_number    = 50
  network_acl_id = aws_vpc.HoLVPC.default_network_acl_id
  protocol       = -1
  cidr_block     = "${chomp(data.http.myip.response_body)}/32"
  rule_action    = "deny"
}
