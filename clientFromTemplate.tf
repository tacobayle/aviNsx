resource "vsphere_tag" "ansible_group_client" {
  name             = "client"
  category_id      = vsphere_tag_category.ansible_group_client.id
}

data "template_file" "client_userdata" {
  count = length(var.clientIps)
  template = file("${path.module}/userdata/client.userdata")
  vars = {
    password     = var.client["password"]
    defaultGw = var.client["defaultGw"]
    pubkey       = file(var.jump["public_key_path"])
    ip         = element(var.clientIps, count.index)
    subnetMask = var.client["subnetMask"]
    netplanFile  = var.client["netplanFile"]
    dnsMain      = var.client["dnsMain"]
    dnsSec       = var.client["dnsSec"]
  }
}
#
data "vsphere_virtual_machine" "client" {
  name          = var.client["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "client" {
  count            = length(var.clientIps)
  name             = "client-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkClient.id
  }

  num_cpus = var.client["cpu"]
  memory = var.client["memory"]
  #wait_for_guest_net_timeout = var.client["wait_for_guest_net_timeout"]
  wait_for_guest_net_routable = var.client["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.client.guest_id
  scsi_type = data.vsphere_virtual_machine.client.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.client.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.client.scsi_controller_scan_count

  disk {
    size             = var.client["disk"]
    label            = "client-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.client.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.client.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.client.id
  }

  tags = [
        vsphere_tag.ansible_group_client.id,
  ]


  vapp {
    properties = {
     hostname    = "client-${count.index}"
     password    = var.client["password"]
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.client_userdata[count.index].rendered)
   }
 }

 connection {
   host        = element(var.clientIps, count.index)
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


}
