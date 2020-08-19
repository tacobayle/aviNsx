# Ansible host file creation

#resource "null_resource" "foo1" {
#
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF > ${var.ansibleHostFile}
#---
#all:
#  children:
#    controller:
#      hosts:
#EOF
#EOD
#  }
#}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo2" {
#  count = var.controller["count"]
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#        ${vsphere_virtual_machine.controller[count.index].default_ip_address}:
#EOF
#EOD
#  }
#}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo3" {
#  depends_on = [null_resource.foo2]
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#      vars:
#        ansible_user: admin
#        ansible_ssh_private_key_file: '~/.ssh/${basename(var.jump["private_key_path"])}'
#EOF
#EOD
#  }
#}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo4" {
#  depends_on = [null_resource.foo3]
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#    backend:
#      hosts:
#EOF
#EOD
#  }
#}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo5" {
#  depends_on = [null_resource.foo4]
#  count = length(var.backendIpsMgt)
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#        ${split("/", element(var.backendIpsMgt, count.index))[0]}:
#EOF
#EOD
#  }
#}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo6" {
#  depends_on = [null_resource.foo5]
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#      vars:
#        ansible_user: admin
#        ansible_ssh_private_key_file: '~/.ssh/${basename(var.jump["private_key_path"])}'
#EOF
#EOD
#  }
#}

# Ansible host file creation (finishing)

#resource "null_resource" "foo7" {
#  depends_on = [null_resource.foo6]
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#  vars:
#    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
#EOF
#EOD
#  }
#}


data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jump.userdata")
  vars = {
    password      = var.jump["password"]
    pubkey        = file(var.jump["public_key_path"])
    avisdkVersion = var.jump["avisdkVersion"]
  }
}
#
data "vsphere_virtual_machine" "jump" {
  name          = var.jump["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "jump" {
  name             = var.jump["name"]
  depends_on = [null_resource.foo6]
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path
  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  num_cpus = var.jump["cpu"]
  memory = var.jump["memory"]
  wait_for_guest_net_timeout = var.jump["wait_for_guest_net_timeout"]
  guest_id = data.vsphere_virtual_machine.jump.guest_id
  scsi_type = data.vsphere_virtual_machine.jump.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.jump.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.jump.scsi_controller_scan_count

  disk {
    size             = var.jump["disk"]
    label            = "jump.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.jump.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.jump.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.jump.id
  }

  vapp {
    properties = {
     hostname    = "jump"
     password    = var.jump["password"]
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.jumpbox_userdata.rendered)
     "mgmt-ip"     = var.jump["mgmt_ip"]
     "mgmt-mask"   = var.jump["mgmt_mask"]
     "default-gw"  = var.jump["default_gw"]

   }
 }

  connection {
   host        = self.default_ip_address
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
  source      = var.ansibleDirectory
  destination = "~/ansible"
  }

}
