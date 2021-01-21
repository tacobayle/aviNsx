#
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vcenter.server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
#
provider "nsxt" {
  host                     = var.nsxt.server
  username                 = var.nsx_user
  password                 = var.nsx_password
  allow_unverified_ssl     = true
  max_retries              = 10
  retry_min_delay          = 500
  retry_max_delay          = 5000
  retry_on_status_codes    = [429]
}
