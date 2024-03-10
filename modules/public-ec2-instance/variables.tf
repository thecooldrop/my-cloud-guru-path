variable "ami_name_pattern_filter" {
  type = string
  default = "al2023-ami-2023.*-x86_64"
  description = "A filter to select AMI to be used to deploy our EC2 instance"
}

variable "private_key_algorithm" {
  type = string
  default = "ED25519"
  description = "Name of algorithm for generating a key-pair"
}

variable "private_key_file_path" {
  type = string
  default = "key.pem"
  description = "Default path at which to write out a private key file"
}

variable "private_key_file_permissions" {
  type = string
  default = "600"
  description = "Permissions to assign to file containing the private key. Permissions should be represented as octal Linux permissions such as 600 or 777"
  validation {
    condition = can(regex("^[0-7][0-7][0-7]$", var.private_key_file_permissions))
    error_message = "The private key file permissions have to consist of three numerical characters between 0 and 7. Valid example 333, invalid example 1234 and 999"
  }
}

variable "key_pair_name" {
  type = string
  default = "instance_key_pair"
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "allowed_instance_ssh_traffic_cidr" {
  type = string
  default = "0.0.0.0/0"
}

variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "subnet_az_name" {
  type = string
  default = "eu-central-1a"
}

variable "subnet_cidr_block" {
  type = string
  default = "10.0.0.0/24"
}


variable "internet_gateway_destination_cidr_block" {
  type = string
  default = "0.0.0.0/24"
}