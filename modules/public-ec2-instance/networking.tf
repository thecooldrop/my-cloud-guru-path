resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.vpc.id
  availability_zone = var.subnet_az_name
  cidr_block = var.subnet_cidr_block
  map_public_ip_on_launch = true
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "public_route_table" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.public.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "igw-route" {
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block = var.internet_gateway_destination_cidr_block
  gateway_id = aws_internet_gateway.igw.id
}
