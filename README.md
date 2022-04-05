# AWS High Availability Infrastructure Setup

## Whats the purpose of this Terraform?

For Rancher QA to easily spin up multiple groups of AWS infrastructure for validating and reproducing issues at Rancher. Each "group" or module would include the following to get a high availability Rancher setup.

- 3 ec2 instances
- 2 target groups
    - one for tcp 443 traffic
    - one for tcp 80 traffic
- 1 network load balancer

This Terraform does not include Route 53 because I'm using my own DNS records.

The main goal of this terraform is to quickly generate the underlying infrastructure so that you can manually install rke on top of that with your own further customizations. See more on how this is made easy by the output demonstrated in a lower section.

## How to use it?

All you need to do to make this terraform work is to clone the repository and add a file called `terraform.tfvars` that sits next to the `main.tf` file. (not the `main.tf` files located in each module)

How the `terraform.tfvars` file should look like:

```tf
# AWS Access Variables

aws_region            = "whatever-region-you-want"
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

## Output

Here is example output that you will receive after running the terraform. You can also get the values again anytime by running: `terraform output`

```tf
reproduction_module_output = {
  "instance_private_ip" = [
    "0.0.0.0",
    "0.0.0.0",
    "0.0.0.0",
  ]
  "instance_public_ip" = [
    "0.0.0.0",
    "0.0.0.0",
    "0.0.0.0",
  ]
  "random_pet_id_for_reproduction" = "sensible-donkey"
  "reproduction_load_balancer_dns_name" = "the-load-balancer-dns-name-you-need"
}
validation_module_output = {
  "instance_private_ip" = [
    "0.0.0.0",
    "0.0.0.0",
    "0.0.0.0",
  ]
  "instance_public_ip" = [
    "0.0.0.0",
    "0.0.0.0",
    "0.0.0.0",
  ]
  "random_pet_id_for_validation" = "certain-hog"
  "validation_load_balancer_dns_name" = "the-load-balancer-dns-name-you-need"
}
```