# Go / Terratest / Terraform to Create Two Rancher HA Setups

# Webhook Hardening Alert

If wanting to harden the webhook, please see the bottom of this README.md BEFORE running `rke up`.

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

# Harden Webhook Guide (TODO: Automate)

1. Add the following to the `cluster.yml` file **DO NOT RUN RKE UP YET**:

  ```yaml
  ssh_key_path: <redacted>
  network:
    plugin: calico
  services:
    kube-api:
      extra_args:
        admission-control-config-file: "/etc/rancher/admission/admission.yaml"
      extra_binds:
        - "/etc/rancher/admission/admission.yaml:/etc/rancher/admission/admission.yaml"
        - "/etc/rancher/admission/kubeconfig:/etc/rancher/admission/kubeconfig"
        - "/etc/rancher/admission/client.csr:/etc/rancher/admission/client.csr"
        - "/etc/rancher/admission/client.key:/etc/rancher/admission/client.key"
  nodes:
  ```

2. SSH into each controlplane ec2 nodes and create these directories.

```sh
sudo mkdir /etc/rancher
sudo mkdir /etc/rancher/admission
sudo chmod 777 /etc/rancher
sudo chmod 777 /etc/rancher/admission
```

3. Then exit the SSH session
4. Then have these files on your local machine, and `scp` them onto the controlplane ec2 nodes.

  ```yaml
  # /etc/rancher/admission/admission.yaml
  apiVersion: apiserver.config.k8s.io/v1
  kind: AdmissionConfiguration
  plugins:
    - name: ValidatingAdmissionWebhook
      configuration:
        apiVersion: apiserver.config.k8s.io/v1
        kind: WebhookAdmissionConfiguration
        kubeConfigFile: "/etc/rancher/admission/kubeconfig"
    - name: MutatingAdmissionWebhook
      configuration:
        apiVersion: apiserver.config.k8s.io/v1
        kind: WebhookAdmissionConfiguration
        kubeConfigFile: "/etc/rancher/admission/kubeconfig"
  ```

  ```yaml
  # /etc/rancher/admission/kubeconfig
  apiVersion: v1
  kind: Config
  users:
  - name: 'rancher-webhook.cattle-system.svc'
    user:
      client-certificate: /etc/rancher/admission/client.csr
      client-key: /etc/rancher/admission/client.key
  ```

5. Run the command: `openssl req -newkey rsa:2048 -nodes -keyout client.key -out client.csr -x509 -days 365`


6. Now run these scp commands:
  - `scp -i ~/your/pem-file.pem admission.yaml ubuntu@0.0.0.0:/etc/rancher/admission/`
  - `scp -i ~/your/pem-file.pem kubeconfig ubuntu@0.0.0.0:/etc/rancher/admission/`
  - `scp -i ~/your/pem-file.pem client.csr ubuntu@0.0.0.0:/etc/rancher/admission/`
  - `scp -i ~/your/pem-file.pem client.key ubuntu@0.0.0.0:/etc/rancher/admission/`
  - Run these 4 commands against every controlplane node

```sh
sudo chmod 777 /etc/rancher/admission/admission.yaml
sudo chmod 777 /etc/rancher/admission/kubeconfig
sudo chmod 777 /etc/rancher/admission/client.csr
sudo chmod 777 /etc/rancher/admission/client.key
```

7. Run `rke up` against the `cluster.yml` file that this repository creates. After adding the additional lines to the `cluster.yml` file.

8. Install Rancher via helm

9. Install Calico CTL On Your Local Machine: https://docs.tigera.io/calico/latest/operations/calicoctl/install

10. Find the IPs needed for the network.yaml.

11. Run the following: `calicoctl get node --allow-version-mismatch -o yaml`

12. If you have 3 controlplane nodes, like the default for this repository sets up, find 3 of these lines. `ipv4IPIPTunnelAddr: <redacted>`

13. Take these 3 IPs and add them to the `network.yaml` file. Replacing `<redacted>` with the IP.

```yaml
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
  name: allow-k8s
  namespace: cattle-system
spec:
  selector: app == 'rancher-webhook'
  types:
    - Ingress
  ingress:
    - action: Allow
      protocol: TCP
      source:
        nets:
          - <redacted>/32
          - <redacted>/32
          - <redacted>/32
      destination:
        selector:
          app == 'rancher-webhook'
```

14.  Then apply the network.yaml with `k apply -f network.yaml`

15. Create a values.yaml and delete the rancher-config

16.  base64 encode the client.csr from earlier.

17. create a values.yaml file

```yaml
# values.yaml
auth:
  clientCA: <base64-string-goes-here>
```

18. delete the rancher-config with `k delete configmap rancher-config -n cattle-system`
19. recreate it with `kubectl --namespace cattle-system create configmap rancher-config --from-file=rancher-webhook=values.yaml`
20. you can check that it was picked up with `helm get values rancher-webhook -n cattle-system`