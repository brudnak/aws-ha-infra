# 🚧 Docs under Construction

# AWS HA RKE Go / Terratest / Terraform

## What is the purpose of this Terraform?

## How to use it?

All you need to do to make this terraform work is to clone the repository and create a file called `terraform.tfvars` that sits next to the main/parent `main.tf. 

How the `terraform.tfvars` file should look like:

```tf
# AWS Access Variables

aws_access_key        = "key-you-generate-in-aws"
aws_secret_key        = "key-you-generate-in-aws"
aws_prefix            = "whatever-you-want-as-prefix"
aws_vpc               = "look-up-your-most-used-vpc"
aws_subnet_a          = "lookup-subnet-a"
aws_subnet_b          = "lookup-subnet-b"
aws_subnet_c          = "lookup-subnet-c"
aws_ami               = "look-up-ami-you-want-probably-one-with-docker"
aws_subnet_id         = "look-up-your-subnet-id"
aws_security_group_id = "look-up-security-group-you-want"
aws_pem_key_name      = "name-of-your-pem-key"

```

