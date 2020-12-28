resource "vsphere_tag" "ansible_group_backend" {
  name             = "backend"
  category_id      = vsphere_tag_category.ansible_group_backend.id
}

data "template_file" "backend_userdata" {
  count = length(var.backendIps)
  template = file("${path.module}/userdata/backend.userdata")
  vars = {
    defaultGw = var.backend["defaultGw"]
    pubkey       = file(var.jump["public_key_path"])
    ip         = element(var.backendIps, count.index)
    subnetMask = var.backend["subnetMask"]
    netplanFile  = var.backend["netplanFile"]
    dnsMain      = var.backend["dnsMain"]
    dnsSec       = var.backend["dnsSec"]
  }
}

resource "vsphere_virtual_machine" "backend" {
  count            = length(var.backendIps)
  name             = "backend-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folderApps.path

  network_interface {
                      network_id = data.vsphere_network.networkBackend.id
  }

  num_cpus = var.backend["cpu"]
  memory = var.backend["memory"]
  #wait_for_guest_net_timeout = var.backend["wait_for_guest_net_timeout"]
  wait_for_guest_net_routable = var.backend["wait_for_guest_net_routable"]
  guest_id = "guestid-backend-${count.index}"


  disk {
    size             = var.backend["disk"]
    label            = "backend-${count.index}.lab_vmdk"
    thin_provisioned = true
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = vsphere_content_library_item.files[1].id
  }

  tags = [
        vsphere_tag.ansible_group_backend.id,
  ]


  vapp {
    properties = {
     hostname    = "backend-${count.index}"
     password    = var.backend["password"]
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.backend_userdata[count.index].rendered)
   }
 }

  connection {
    host        = element(var.backendIps, count.index)
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
