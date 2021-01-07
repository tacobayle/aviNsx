data "nsxt_policy_transport_zone" "tz" {
  display_name = var.avi_cloud.transportZone
}

resource "nsxt_policy_segment" "networkMgmt" {
  display_name        = var.networkMgmt["name"]
  connectivity_path   = "/infra/tier-1s/cgw"
  transport_zone_path = data.nsxt_policy_transport_zone.tz.path
  #domain_name         = "runvmc.local"
  description         = "Network Segment built by Terraform for Avi"
  subnet {
    cidr        = "${cidrhost(var.networkMgmt["cidr"], 1)}/${split("/", var.networkMgmt["cidr"])[1]}"
    dhcp_ranges = ["${cidrhost(var.networkMgmt["cidr"], var.networkMgmt["networkRangeBegin"])}-${cidrhost(var.networkMgmt["cidr"], var.networkMgmt["networkRangeEnd"])}"]
  }
}


resource "nsxt_vm_tags" "backendTags" {
  count = length(var.backendIps)
  instance_id = vsphere_virtual_machine.backend[count.index].id
  tag {
    tag   = var.nsxtGroup["tag"]
  }
}
