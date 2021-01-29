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

output "Destroy_Command_Below" {
  value = "\nPlease run this command below in your aviNsx directory:\n\nssh -o StrictHostKeyChecking=no -i ${var.jump.private_key_path} -t ubuntu@${vsphere_virtual_machine.jump.default_ip_address} 'git clone ${var.ansible.aviPbAbsentUrl} --branch ${var.ansible.aviPbAbsentTag} ; cd ${split("/", var.ansible.aviPbAbsentUrl)[4]} ; ansible-playbook local.yml --extra-vars @${var.controller.aviCredsJsonFile}' ; sleep 20 ; terraform destroy -auto-approve\n"
  description = "command to destroy the infra"
}