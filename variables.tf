#
### VMware variables
#
variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
#
#
variable "dc" {
  default     = "N1-DC"
}
#
variable "cluster" {
  default     = "N1-Cluster1"
}
#
variable "datastore" {
  default     = "vsanDatastore"
}
#
variable "networkMgt" {
  default     = "N1_vds-01_management"
}
#
variable "folder" {
  default     = "N1-AVI"
}
#
variable "resource_pool" {
  default     = "N1-Cluster1/Resources"
}
#
variable "controller" {
  type = map
  default = {
    cpu = 8
    memory = 24768
    disk = 128
    count = "1"
    version = "20.1.1-9071"
    floatingIp = "10.0.0.200"
    wait_for_guest_net_timeout = 2
    private_key_path = "~/.ssh/cloudKey"
    mgmt_ip = "10.0.0.201"
    mgmt_mask = "255.255.255.0"
    default_gw = "10.0.0.1"
    dnsMain = "172.18.0.15"
    ntpMain = "172.18.0.15"
    environment = "VMWARE"
  }
}
#
variable "wait_for_guest_net_timeout" {
  default = "5"
}
#
variable "jump" {
  type = map
  default = {
    name = "jump"
    cpu = 1
    memory = 2048
    disk = 24
    password = "Avi_2020"
    public_key_path = "~/.ssh/id_rsa/ubuntu-bionic-18.04-cloudimg-template.key.pub"
    private_key_path = "~/.ssh/id_rsa/ubuntu-bionic-18.04-cloudimg-template.key"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    aviSdkVersion = "18.2.9"
    ipCidr = "10.0.0.210/24"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.0.0.1"
    dnsMain = "172.18.0.15"
    username = "ubuntu"
  }
}
#
variable "backend" {
  type = map
  default = {
    cpu = 1
    memory = 2048
    disk = 10
    password = "Avi_2020"
    network = "N1-T1_Segment-Backend_10.7.6.0-24"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.7.6.1"
    dnsMain = "172.18.0.15"
    dnsSec = "10.206.8.131"
    subnetMask = "/24"
  }
}
#
variable "backendIps" {
  type = list
  default = ["10.7.6.10", "10.7.6.11"]
}
#
variable "client" {
  type = map
  default = {
    cpu = 1
    memory = 2048
    disk = 10
    password = "Avi_2020"
    network = "N1-T1_Segment-VIP-A_10.7.4.0-24"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    defaultGw = "10.7.4.1"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    dnsMain = "172.18.0.15"
    dnsSec = "10.206.8.131"
    subnetMask = "/24"
  }
}
#
variable "clientIps" {
  type = list
  default = ["10.7.4.10"]
}
#
# NSX-T Variables
#
variable "nsx_user" {}
variable "nsx_password" {}
variable "nsx_server" {}
#
### Ansible variables
#
variable "avi_password" {}
variable "avi_controller" {}
variable "avi_user" {}
#
variable "ansibleDirectory" {
  default = "ansible"
}
#
variable "avi_cloud" {
  type = map
  default = {
    name = "cloudNsxt"
    vtype = "CLOUD_NSXT"
    transportZone = "TZ_nested_nsx-overlay"
    network = "N1-T1_Segment-AVI-SE-Mgt_10.7.3.0-24"
    networkType = "V4"
    networkVrf = "management"
    networkRangeBegin = "11"
    networkRangeEnd = "50"
    dhcp_enabled = "false"
    tier1 = "N1-T1_AVI-SE-Mgmt"
    vcenterContentLibrary = "Avi Content Library"
    obj_name_prefix = "NSXTCLOUD"
  }
}
#
variable "avi_network_vip" {
  type = map
  default = {
    name = "N1-T1_Segment-VIP-A_10.7.4.0-24"
    type = "V4"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
    dhcp_enabled = "false"
    tier1 = "N1-T1_AVI-VIP-A"
    networkRangeBegin = "11"
    networkRangeEnd = "50"
    gwAddr ="1"
  }
}
#
variable "avi_network_backend" {
  type = map
  default = {
    name = "N1-T1_Segment-Backend_10.7.6.0-24"
    type = "V4"
    dhcp_enabled = "false"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
  }
}
#
variable "domain" {
  type = map
  default = {
    name = "avi.altherr.info"
  }
}
#
variable "nsxtGroup" {
  type = map
  default = {
    name = "n1-avi-backend-servers-01"
    tag = "n1-avi-backend-servers-01"
  }
}
#
variable "ansible" {
  type = map
  default = {
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.32"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    aviConfigureTag = "v1.68"
    version = "2.9.12"
  }
}
