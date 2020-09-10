resource "nsxt_vm_tags" "backendTags" {
  count = length(var.backendIps)
  instance_id = vsphere_virtual_machine.backend[count.index].id
  tag {
    tag   = var.nsxtGroup["tag"]
  }

}
