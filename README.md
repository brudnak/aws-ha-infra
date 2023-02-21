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

After you run the `TestHaSetup` look in the `terratest` folder, you'll see two additional folders created:

- high-availability-1
- high-availability-2

These will contain the cluster config you can run `rke up` against with whatever version of `rke` you have preinstalled on your local.

And a pre-configured shell install script you can run `bash install.sh` and it will install Rancher for you.

The cluster config file is created to use the default k8s version for the `rke` version you're using. You may need to add the k8s version field.

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
  global_cattle_psp_enabled: true
ha-2:
  image: v2.7.2-rc3
  chart: 2.7.2-rc3
  global_cattle_psp_enabled: false
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

### How Long Does it Take to Run?

Completes `TestHaSetup` in ~4 minutes
