# use aws provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}

module "ha-1" {
  source                = "./modules/aws-high-availability-infrastructure"
  aws_prefix            = var.aws_prefix
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  aws_vpc               = var.aws_vpc
  aws_subnet_a          = var.aws_subnet_a
  aws_subnet_b          = var.aws_subnet_b
  aws_subnet_c          = var.aws_subnet_c
  aws_ami               = var.aws_ami
  aws_subnet_id         = var.aws_subnet_id
  aws_security_group_id = var.aws_security_group_id
  aws_pem_key_name      = var.aws_pem_key_name
}

module "ha-2" {
  source                = "./modules/aws-high-availability-infrastructure"
  aws_prefix            = var.aws_prefix
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  aws_vpc               = var.aws_vpc
  aws_subnet_a          = var.aws_subnet_a
  aws_subnet_b          = var.aws_subnet_b
  aws_subnet_c          = var.aws_subnet_c
  aws_ami               = var.aws_ami
  aws_subnet_id         = var.aws_subnet_id
  aws_security_group_id = var.aws_security_group_id
  aws_pem_key_name      = var.aws_pem_key_name
}

module "ha-3" {
  source                = "./modules/aws-high-availability-infrastructure"
  aws_prefix            = var.aws_prefix
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  aws_vpc               = var.aws_vpc
  aws_subnet_a          = var.aws_subnet_a
  aws_subnet_b          = var.aws_subnet_b
  aws_subnet_c          = var.aws_subnet_c
  aws_ami               = var.aws_ami
  aws_subnet_id         = var.aws_subnet_id
  aws_security_group_id = var.aws_security_group_id
  aws_pem_key_name      = var.aws_pem_key_name
}

module "ha-4" {
  source                = "./modules/aws-high-availability-infrastructure"
  aws_prefix            = var.aws_prefix
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  aws_vpc               = var.aws_vpc
  aws_subnet_a          = var.aws_subnet_a
  aws_subnet_b          = var.aws_subnet_b
  aws_subnet_c          = var.aws_subnet_c
  aws_ami               = var.aws_ami
  aws_subnet_id         = var.aws_subnet_id
  aws_security_group_id = var.aws_security_group_id
  aws_pem_key_name      = var.aws_pem_key_name
}

module "ha-5" {
  source                = "./modules/aws-high-availability-infrastructure"
  aws_prefix            = var.aws_prefix
  aws_access_key        = var.aws_access_key
  aws_secret_key        = var.aws_secret_key
  aws_vpc               = var.aws_vpc
  aws_subnet_a          = var.aws_subnet_a
  aws_subnet_b          = var.aws_subnet_b
  aws_subnet_c          = var.aws_subnet_c
  aws_ami               = var.aws_ami
  aws_subnet_id         = var.aws_subnet_id
  aws_security_group_id = var.aws_security_group_id
  aws_pem_key_name      = var.aws_pem_key_name
}
