output "hostname" {
    value = "${softlayer_virtual_guest.bastion.*.name}"
}

output "public_ip" {
    value = "${softlayer_virtual_guest.bastion.*.ipv4_address}"
}

output "private_ip" {
    value = "${softlayer_virtual_guest.bastion.*.ipv4_address_private}"
}
