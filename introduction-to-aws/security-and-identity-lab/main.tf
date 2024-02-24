terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.38.0"
    }
  }
}

locals {
  user_ids = ["1", "2", "3"]
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_iam_group" "s3-support-group" {
  name = "S3-Support"
}

resource "aws_iam_group" "ec2-support-group" {
  name = "EC2-Support"
}

resource "aws_iam_group" "EC2-Admin" {
  name = "EC2-Admin"
}

resource "aws_iam_user" "users" {
  for_each = toset(local.user_ids)
  name     = "user-${each.key}"
}


resource "aws_iam_user_login_profile" "users-login-profiles" {
  for_each = aws_iam_user.users
  user     = each.value.name
  pgp_key  = file("public.gpg")
}


resource "aws_iam_group_membership" "s3-support-members" {
  name  = "s3-support-members"
  group = aws_iam_group.s3-support-group.name
  users = [
    aws_iam_user.users["1"].name
  ]
}
