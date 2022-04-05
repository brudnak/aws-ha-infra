# use aws provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}

module "reproduction" {
  source                = "./modules/reproduction"
  aws_prefix            = var.aws_prefix
  aws_region            = var.aws_region
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

module "validation" {
  source                = "./modules/validation"
  aws_prefix            = var.aws_prefix
  aws_region            = var.aws_region
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


variable "aws_prefix" {}
variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_vpc" {}
variable "aws_subnet_a" {}
variable "aws_subnet_b" {}
variable "aws_subnet_c" {}
variable "aws_ami" {}
variable "aws_subnet_id" {}
variable "aws_security_group_id" {}
variable "aws_pem_key_name" {}

output "reproduction_module_output" {
  value = module.reproduction
}

output "validation_module_output" {
  value = module.validation
}
