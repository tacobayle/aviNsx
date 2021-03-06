data "vsphere_datacenter" "dc" {
  name = var.vcenter.dc
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vcenter.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name = var.vcenter.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vcenter.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkMgt" {
  depends_on = [time_sleep.wait_segment]
  name = var.networkMgt.name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkBackend" {
  depends_on = [time_sleep.wait_segment]
  name = var.backend["network"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "networkClient" {
  depends_on = [time_sleep.wait_segment]
  name = var.client["network"]
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folderAvi" {
  path          = var.vcenter.folderAvi
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folderApps" {
  path          = var.vcenter.folderApps
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_folder" "folderSes" {
  count = length(var.nsxt.vcenter.serviceEngineGroup)
  path          = var.nsxt.vcenter.serviceEngineGroup[count.index].vcenter_folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_tag_category" "ansible_group_backend" {
  name = "ansible_group_backend"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_client" {
  name = "ansible_group_client"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_controller" {
  name = "ansible_group_controller"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "ansible_group_jump" {
  name = "ansible_group_jump"
  cardinality = "SINGLE"
  associable_types = [
    "VirtualMachine",
  ]
}