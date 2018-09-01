variable "ssh_keys" {
    description = "default public key, define multiple keys as comma separated string"
}

variable "region" {
}

variable "domain" {
}

variable "name" {
}

variable "path_private_key" {
    description = "path to the private id key for ssh connections"
}

variable "port" {}
variable "username" {}
variable "password" {}

provider "softlayer" {}


resource "softlayer_virtual_guest" "bastion" {
    name                     = "${var.name}-${var.region}"
    domain                   = "${var.domain}"
    ssh_keys                 = ["${split(",", replace(var.ssh_keys, "/,\\s?$/", ""))}"]
    image                    = "DEBIAN_9_64"
    region                   = "${var.region}"
    hourly_billing           = true
    public_network_speed     = 100
    private_network_only     = false
    cpu                      = 4
    ram                      = 4096
    disks                    = [25]
    local_disk               = false

    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.path_private_key} ${path.module}/user_data.sh root@${self.ipv4_address_private}:/tmp"
    }

    provisioner "local-exec" {
        command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.path_private_key} -p 22 root@${self.ipv4_address_private} /tmp/user_data.sh ${var.port} ${var.username} ${var.password}"
    }
}