data "nsxt_policy_transport_zone" "tz" {
  display_name = var.avi_cloud.transportZone
}

data "nsxt_policy_tier1_gateway" "tier1_router" {
  display_name = var.avi_network_vip.tier1
}

//resource "nsxt_policy_segment" "networkVip" {
//  display_name        = var.avi_network_vip.name
//  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_router.path
//  transport_zone_path = data.nsxt_policy_transport_zone.tz.path
//  #domain_name         = "runvmc.local"
//  description         = "Network Segment built by Terraform"
//  subnet {
//    cidr        = "${cidrhost(var.avi_network_vip["cidr"], 1)}/${split("/", var.avi_network_vip["cidr"])[1]}"
//    //    dhcp_ranges = ["${cidrhost(var.networkBackend["cidr"], var.networkBackend["networkRangeBegin"])}-${cidrhost(var.networkBackend["cidr"], var.networkBackend["networkRangeEnd"])}"]
//
//  }
//}
//
//resource "nsxt_policy_segment" "networkBackend" {
//  display_name        = var.avi_network_vip.name
//  connectivity_path   = data.nsxt_policy_tier1_gateway.tier1_router.path
//  transport_zone_path = data.nsxt_policy_transport_zone.tz.path
//  #domain_name         = "runvmc.local"
//  description         = "Network Segment built by Terraform"
//  subnet {
//    cidr        = "${cidrhost(var.avi_network_backend["cidr"], 1)}/${split("/", var.avi_network_backend["cidr"])[1]}"
//    //    dhcp_ranges = ["${cidrhost(var.networkBackend["cidr"], var.networkBackend["networkRangeBegin"])}-${cidrhost(var.networkBackend["cidr"], var.networkBackend["networkRangeEnd"])}"]
//
//  }
//}
//
//resource "time_sleep" "wait_60_seconds" {
//  depends_on = [nsxt_policy_segment.networkVip, nsxt_policy_segment.networkBackend]
//  create_duration = "60s"
//}

resource "nsxt_vm_tags" "backendTags" {
  count = length(var.backendIps)
  instance_id = vsphere_virtual_machine.backend[count.index].id
  tag {
    tag   = var.nsxtGroup["tag"]
  }
}
