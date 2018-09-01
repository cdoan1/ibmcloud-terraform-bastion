# ibmcloud-terraform-bastion

This is a terraform module to allow the quick bootstrap of a bastion node
in the IBM Cloud (softlayer) platform, given a data center.

This module is based on similar modules created for AWS, AZURE, ...

# requirements

1. requires that you VPN into the softlayer account because we will be
   doing everything from the private interface (eth0) even through (eth1)
   is available.

# goals

- [x] allow only non-root login
- [x] allow only login from private network
- [x] block all incoming traffic from `public` address
- [x] allow ssh on non-standard port, `53211`
- [x] install docker


# Usage

```
module "bastion_host" {
  source           = "./modules/ibmcloud-terraform-bastion"
  name             = "sebastion-1"
  ssh_keys         = "92..."
  region           = "tor01"
  domain           = "test.com"
  port             = "53211"
  username         = "ec2-user"
  password         = "changeit"
  path_private_key = "~/.ssh/id_rsa"
}
```

