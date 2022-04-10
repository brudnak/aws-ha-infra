# AWS High Availability Base Infrastructure Setup

## What is the purpose of this Terraform?
For Rancher QA to easily deploy and manage AWS infrastructure for High Availability testing. This creates a base level of infrastructure and outputs public, and private IP addresses for the various nodes. You can quickly transfer these to a config file to run `rke up` against.


This Terraform does not include Route 53 DNS records. This is so that you can use your own domain name.

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

## Output

Here is example output that you will receive after running the terraform. You can also get the values again anytime by running: `terraform output`

```tf
Reproduction = {
  "balancer_dns_name" = "load balancer to create DNS record with: your-nlb-dns.com"
  "instance_private_ip" = [
    "private IP for rke config: 0.0.0.0",
    "private IP for rke config: 0.0.0.0",
    "private IP for rke config: 0.0.0.0",
  ]
  "instance_public_ip" = [
    "public IP for rke config: 0.0.0.0",
    "public IP for rke config: 0.0.0.0",
    "public IP for rke config: 0.0.0.0",
  ]
  "random_pet_id" = "random ID to identify aws resources: ruling-marmot"
}
Validation = {
  "balancer_dns_name" = "load balancer to create DNS record with: your-nlb-dns.com"
  "instance_private_ip" = [
    "private IP for rke config: 0.0.0.0",
    "private IP for rke config: 0.0.0.0",
    "private IP for rke config: 0.0.0.0",
  ]
  "instance_public_ip" = [
    "public IP for rke config: 0.0.0.0",
    "public IP for rke config: 0.0.0.0",
    "public IP for rke config: 0.0.0.0",
  ]
  "random_pet_id" = "random ID to identify aws resources: engaging-wahoo"
}
```

### Now you can easily use this output to run `rke up` against.

>Copy / paste the output from Terraform into a config file and run `rke up` against it.

```yaml
ssh_key_path:
kubernetes_version:

nodes:
  - address:
    internal_address:
    user:
    role: [etcd, controlplane, worker]

  - address:
    internal_address:
    user:
    role: [etcd, controlplane, worker]

  - address:
    internal_address:
    user: 
    role: [etcd, controlplane, worker]
```