resource "random_pet" "random_pet" {

  keepers = {
    aws_prefix = "${var.aws_prefix}"
  }

  length    = 2
  separator = "-"
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


resource "aws_instance" "aws_instance" {
  count                  = 3
  ami                    = var.aws_ami
  instance_type          = "t3.2xlarge"
  subnet_id              = var.aws_subnet_id
  vpc_security_group_ids = [var.aws_security_group_id]
  key_name               = var.aws_pem_key_name

  root_block_device {
    volume_size = 150
  }

  tags = {
    Name = "${random_pet.random_pet.keepers.aws_prefix}-${random_pet.random_pet.id}${formatdate("MMMDDYY", timestamp())}"
  }
}
