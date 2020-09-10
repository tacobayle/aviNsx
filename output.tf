# Outputs for Terraform

output "jump" {
  value = vsphere_virtual_machine.jump.default_ip_address
}

output "controllers" {
  value = vsphere_virtual_machine.controller.*.default_ip_address
}

output "backend" {
  value = var.backendIps.*
}

output "client" {
  value = var.clientIps.*
}

output "loadcommand" {
  value = "while true ; do ab -n 1000 -c 1000 https://a.b.c.d/ ; done"
}

#output "destroy" {
#  value = "ssh -o StrictHostKeyChecking=no -i ~/.ssh/${basename(var.jump["private_key_path"])} -t ubuntu@${vsphere_virtual_machine.jump.default_ip_address} 'ansible-pull --url ${var.ansible["aviPbAbsentUrl"]} --extra-vars @~/ansible/vars/fromTerraform.yml --extra-vars @~/ansible/vars/creds.json' ; sleep 5 ; terraform destroy -auto-approve"
#  description = "command to destroy the infra"
#}

output "destroy" {
  value = "ssh -o StrictHostKeyChecking=no -i ${var.jump["private_key_path"]} -t ubuntu@${vsphere_virtual_machine.jump.default_ip_address} 'ansible-pull --url ${var.ansible["aviPbAbsentUrl"]} --extra-vars @~/ansible/vars/fromTerraform.yml --extra-vars @~/ansible/vars/creds.json' ; sleep 5 ; terraform destroy -auto-approve"
  description = "command to destroy the infra"
}
