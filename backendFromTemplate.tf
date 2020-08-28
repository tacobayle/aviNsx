


data "template_file" "backend_userdata" {
  count = length(var.backendIps)
  template = file("${path.module}/userdata/backend.userdata")
  vars = {
    password     = var.backend["password"]
    defaultGwMgt = var.backend["defaultGwMgt"]
    pubkey       = file(var.jump["public_key_path"])
    cidr         = element(var.backendIps, count.index)
    ip = split("/", element(var.backendIps, count.index))[0]
    netplanFile  = var.backend["netplanFile"]
    dnsMain      = var.backend["dnsMain"]
    dnsSec       = var.backend["dnsSec"]
  }
}
#
data "vsphere_virtual_machine" "backend" {
  name          = var.backend["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "backend" {
  count            = length(var.backendIps)
  name             = "backend-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path

  network_interface {
                      network_id = data.vsphere_network.networkBackend.id
  }

  num_cpus = var.backend["cpu"]
  memory = var.backend["memory"]
  #wait_for_guest_net_timeout = var.backend["wait_for_guest_net_timeout"]
  wait_for_guest_net_routable = var.backend["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.backend.guest_id
  scsi_type = data.vsphere_virtual_machine.backend.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.backend.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.backend.scsi_controller_scan_count

  disk {
    size             = var.backend["disk"]
    label            = "backend-${count.index}.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.backend.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.backend.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.backend.id
  }

  vapp {
    properties = {
     hostname    = "backend-${count.index}"
     password    = var.backend["password"]
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.backend_userdata[count.index].rendered)
   }
 }

  connection {
    host        = split("/", element(var.backendIps, count.index))[0]
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
