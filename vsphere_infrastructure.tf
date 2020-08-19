#
data "vsphere_datacenter" "dc" {
  name = var.dc
}
#
data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
data "vsphere_datastore" "datastore" {
  name = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
#data "vsphere_distributed_virtual_switch" "dvs" {
#  name          = "wdc-06-vc12-dvs"
#  datacenter_id = data.vsphere_datacenter.dc.id
#}
#
data "vsphere_network" "networkMgt" {
  name = var.networkMgt
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
#data "vsphere_network" "networkAviMgt" {
#  name = var.avi_cloud["network"]
#  datacenter_id = data.vsphere_datacenter.dc.id
#}
#
#data "vsphere_network" "networkBackend" {
#  name = var.backend["network"]
#  datacenter_id = data.vsphere_datacenter.dc.id
#}
#
#data "vsphere_network" "networkClient" {
#  name = var.client["network"]
#  datacenter_id = data.vsphere_datacenter.dc.id
#}
#
resource "vsphere_folder" "folder" {
  path          = var.folder
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}
