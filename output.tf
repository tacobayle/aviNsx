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
  value = "while true ; do ab -n 200 -c 200 https://a.b.c.d/ ; done"
}

output "destroy" {
  value = "ssh -o StrictHostKeyChecking=no -i ${var.jump.private_key_path} -t ubuntu@${vsphere_virtual_machine.jump.default_ip_address} 'git clone ${var.ansible.aviPbAbsentUrl} --branch ${var.ansible.aviPbAbsentTag} ; cd ${split("/", var.ansible.aviPbAbsentUrl)[4]} ; ansible-playbook local.yml --extra-vars @${var.controller.aviCredsJsonFile} --extra-vars @${var.ansible.jsonFile} --extra-vars @${var.ansible.yamlFile}' ; sleep 20 ; terraform destroy -auto-approve"
  description = "command to destroy the infra"
}
