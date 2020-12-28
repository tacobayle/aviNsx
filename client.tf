resource "vsphere_tag" "ansible_group_client" {
  name             = "client"
  category_id      = vsphere_tag_category.ansible_group_client.id
}

data "template_file" "client_userdata" {
  count = length(var.clientIps)
  template = file("${path.module}/userdata/client.userdata")
  vars = {
    defaultGw = var.client["defaultGw"]
    pubkey       = file(var.jump["public_key_path"])
    ip         = element(var.clientIps, count.index)
    subnetMask = var.client["subnetMask"]
    netplanFile  = var.client["netplanFile"]
    dnsMain      = var.client["dnsMain"]
    dnsSec       = var.client["dnsSec"]
  }
}

resource "vsphere_virtual_machine" "client" {
  count            = length(var.clientIps)
  name             = "client-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folderApps.path

  network_interface {
                      network_id = data.vsphere_network.networkClient.id
  }

  num_cpus = var.client["cpu"]
  memory = var.client["memory"]
  #wait_for_guest_net_timeout = var.client["wait_for_guest_net_timeout"]
  wait_for_guest_net_routable = var.client["wait_for_guest_net_routable"]
  guest_id = "guestid-client-${count.index}"

  disk {
    size             = var.client["disk"]
    label            = "client-${count.index}.lab_vmdk"
    thin_provisioned = true
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = vsphere_content_library_item.files[1].id
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
