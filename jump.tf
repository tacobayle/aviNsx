resource "vsphere_tag" "ansible_group_jump" {
  name             = "jump"
  category_id      = vsphere_tag_category.ansible_group_jump.id
}

data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jump.userdata")
  vars = {
    pubkey        = file(var.jump["public_key_path"])
    aviSdkVersion = var.jump["aviSdkVersion"]
    ansibleVersion = var.ansible["version"]
    ipCidr  = var.jump["ipCidr"]
    ip = split("/", var.jump["ipCidr"])[0]
    defaultGw = var.jump["defaultGw"]
    dnsMain      = var.jump["dnsMain"]
    netplanFile = var.jump["netplanFile"]
    vsphere_user  = var.vsphere_user
    vsphere_password = var.vsphere_password
    vsphere_server = var.vsphere_server
    username = var.jump["username"]
    privateKey = var.jump["private_key_path"]
  }
}

resource "vsphere_virtual_machine" "jump" {
  name = var.jump["name"]
  datastore_id = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder = vsphere_folder.folderAvi.path
  network_interface {
    network_id = data.vsphere_network.networkMgt.id
  }

  num_cpus = var.jump["cpu"]
  memory = var.jump["memory"]
  wait_for_guest_net_timeout = 10
  wait_for_guest_net_routable = var.jump["wait_for_guest_net_routable"]
  guest_id = "guestid-jump"

  disk {
    size = var.jump["disk"]
    label = "jump.lab_vmdk"
    thin_provisioned = true
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = vsphere_content_library_item.files[1].id
  }

  tags = [
    vsphere_tag.ansible_group_jump.id,
  ]

  vapp {
    properties = {
      hostname = "jump"
      password = var.jump["password"]
      public-keys = file(var.jump["public_key_path"])
      user-data = base64encode(data.template_file.jumpbox_userdata.rendered)
    }
  }
}