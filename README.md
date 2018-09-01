# ibmcloud-terraform-bastion

This is a terraform module to allow the quick bootstrap of a bastion node
in the IBM Cloud (softlayer) platform, given a data center.

This module is based on similar modules created for AWS, AZURE, ...

# requirements

1. requires that you VPN into the softlayer account because we will be
   doing everything from the private interface (eth0) even through (eth1)
   is available.

# goals

- [ ] allow only non-root login
- [ ] allow only login from private network
- [ ] block all incoming traffic from `public` address
- [ ] allow ssh on non-standard port, `22122`
- [ ] install docker


# Usage

```
# Public Bastion Host Example
module "bastion_host" {
  source       = "../modules/ibmcloud-terraform-bastion"
  key_name     = "${var.aws_key_name}"
  dns_zone     = "${data.az.rkcloud.name}"
  env          = "${var.env}"
  hostname     = "bastion.${var.stack}-${var.env}-infra"
  additional_user_data_script = "${data.template_file.consul_agent_json.rendered}"
  subnet_ids   = "${module.vpc.public_subnets}"
}
```

