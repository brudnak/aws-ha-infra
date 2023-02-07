# Go / Terratest / Terraform to Create Two Rancher HA Setups

## What is the purpose of this Terraform?

For Rancher QA to easily create HA Rancher setups in AWS with RKE1 as the base. 

This will create two folders next to `ha_test.go`

- high-availability-1
- high-availability-2

These folders will contain a cluster.yml pre-configured to run `rke up` against with whatever rke version you want.

And also a preconfigured installation script that you can run `bash install.sh` against.

## How to use it?

All you need to do to make this terraform work is to clone the repository and create a file called `tool-config.yml` that sits next to the `README.md`. 

How the `tool-config.yml` file should look like:

```yaml
local:
  pem_path: "your-local-path-to-the-pem-file-you-use-for-aws"
rancher:
  bootstrap_password: whatever-bootstrap-password-you-want
  le_email: email-you-want-to-use-for-lets-encrypt
ha-1:
  image: v2.7.1
  chart: 2.7.1
ha-2:
  image: v2.7-head
  chart: 2.7.1
tf_vars:
  aws_access_key: your-aws-access-key
  aws_secret_key: your-aws-secret-key
  aws_prefix: aws-prefix-should-only-be-3-characters-like-your-initials
  aws_vpc: aws-vpc-you-want-to-use
  aws_subnet_a: your-subnet-a
  aws_subnet_b: your-subnet-b
  aws_subnet_c: your-subnet-c
  aws_ami: whatever-ami-you-want-one-with-docker
  aws_subnet_id: -your-subnet-id
  aws_security_group_id: whatever-security-group-you-want
  aws_pem_key_name: your-aws-pem-key-name-in-aws-no-file-extension
  aws_route53_fqdn: something.something.something
```

Then you just need to run this function in `ha_test.go` >>> `TestHaSetup`

There is also a cleanup function that you can run in `ha_test.go` >>> `TestHACleanup`
