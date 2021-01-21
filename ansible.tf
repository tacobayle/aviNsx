
resource "null_resource" "foo" {
  depends_on = [vsphere_virtual_machine.jump]
  connection {
    host        = split("/", var.jump["ipCidr"])[0]
    type        = "ssh"
    agent       = false
    user        = "ubuntu"
    private_key = file(var.jump["private_key_path"])
  }

  provisioner "remote-exec" {
    inline      = [
      "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
    ]
  }

  provisioner "file" {
    source      = var.jump["private_key_path"]
    destination = "~/.ssh/${basename(var.jump["private_key_path"])}"
  }

  provisioner "file" {
    source      = var.ansible.directory
    destination = "~/ansible"
  }

  provisioner "remote-exec" {
    inline      = [
      "chmod 600 ~/.ssh/${basename(var.jump["private_key_path"])}",
      "cd ~/ansible ; git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag} ; cd ${split("/", var.ansible.aviConfigureUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars '{\"avi_username\": ${jsonencode(var.avi_username)}, \"avi_password\": ${jsonencode(var.avi_password)}, \"avi_version\": ${split("-", basename(var.contentLibrary.files[0]))[1]}, \"controllerPrivateIps\": ${jsonencode(vsphere_virtual_machine.controller.*.default_ip_address)}, \"controller\": ${jsonencode(var.controller)}, \"nsx_user\": ${jsonencode(var.nsx_user)}, \"nsx_password\": ${jsonencode(var.nsx_password)}, \"nsx_vsphere_user\": ${jsonencode(var.nsx_vsphere_user)}, \"nsx_vsphere_password\": ${jsonencode(var.nsx_vsphere_password)}, \"nsxt\": ${jsonencode(var.nsxt)}, \"domain\": ${jsonencode(var.domain)}, \"avi_backend_servers_nsxt\": ${jsonencode(var.backendIps)}}'",
    ]
  }
}

