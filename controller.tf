resource "vsphere_tag" "ansible_group_controller" {
  name             = "controller"
  category_id      = vsphere_tag_category.ansible_group_controller.id
}

resource "vsphere_virtual_machine" "controller" {
  count            = var.controller["count"]
  name             = "${split(".ova", basename(var.contentLibrary.files[0]))[0]}-${count.index}"
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folderAvi.path
  network_interface {
    network_id = data.vsphere_network.networkMgt.id
  }

  num_cpus = var.controller["cpu"]
  memory = var.controller["memory"]
  wait_for_guest_net_timeout = var.controller["wait_for_guest_net_timeout"]
  guest_id = "guestid-${split(".ova", basename(var.contentLibrary.files[0]))[0]}-${count.index}"

  disk {
    size             = var.controller["disk"]
    label            = "controller-${split(".ova", basename(var.contentLibrary.files[0]))[0]}-${count.index}.lab_vmdk"
    thin_provisioned = true
  }

  clone {
    template_uuid = vsphere_content_library_item.files[0].id
  }

  tags = [
        vsphere_tag.ansible_group_controller.id,
  ]

  vapp {
    properties = {
      "mgmt-ip"     = var.controller["mgmt_ip"]
      "mgmt-mask"   = var.controller["mgmt_mask"]
      "default-gw"  = var.controller["default_gw"]
   }
  }
}
