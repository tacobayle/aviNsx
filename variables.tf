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
    cpu = 2
    memory = 4096
    disk = 32
    password = "Avi_2020"
    public_key_path = "~/n1-ubuntu-20.04-template.key.pub"
    private_key_path = "~/n1-ubuntu-20.04-template.key"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    aviSdkVersion = "18.2.9"
    ipMgmt = "10.0.0.210/24"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGwMgt = "10.0.0.1"
    dnsMain = "172.18.0.15"
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
    defaultGwMgt = "10.7.6.1"
    dnsMain = "172.18.0.15"
    dnsSec = "10.206.8.131"
  }
}
#
variable "backendIps" {
  type = list
  default = ["10.7.6.10/24", "10.7.6.11/24"]
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
    defaultGwMgt = "10.7.4.1"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    dnsMain = "172.18.0.15"
    dnsSec = "10.206.8.131"
  }
}
#
variable "clientIps" {
  type = list
  default = ["10.7.4.10/24"]
}
#
# NSX-T Variable
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
variable "ansibleHostFile" {
  default = "ansible/hosts"
}
#
variable "ansibleDirectory" {
  default = "ansible"
}
#
variable "avi_cloud" {
  type = map
  default = {
    name = "CloudNsxt"
    vtype = "CLOUD_NSXT"
    transportZone = "TZ_nested_nsx-overlay"
    network = "N1-T1_Segment-AVI-SE-Mgt_10.7.3.0-24"
    dhcp_enabled = "false"
    tier1 = "N1-T1_AVI-SE-Mgmt"
    vcenterContentLibrary = "Avi Content Library"
  }
}
#
variable "avi_network_vip" {
  type = map
  default = {
    name = "N1-T1_Segment-VIP-A_10.7.4.0-24"
    subnet = "10.7.4.0/24"
    begin = "10.7.4.11"
    end = "10.7.4.99"
    type = "V4"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
    dhcp_enabled = "false"
    tier1 = "N1-T1_AVI-VIP-A"
  }
}
#
variable "avi_network_backend" {
  type = map
  default = {
    subnet = "10.7.6.0/24"
    type = "V4"
    dhcp_enabled = "no"
    exclude_discovered_subnets = "true"
    vcenter_dvs = "true"
  }
}
#
variable "ipam" {
  type = map
  default = {
    name = "ipam-avi"
  }
}
#
variable "domain" {
  type = map
  default = {
    name = "nsx.avidemo.fr"
  }
}
#
# please keep the blank line after default = <<EOT
#
variable "avi_healthmonitor" {
  default = <<EOT

  - name: &hm0 hm1
    receive_timeout: 1
    failed_checks: 2
    send_interval: 1
    successful_checks: 2
    type: HEALTH_MONITOR_HTTP
    http_request: "HEAD / HTTP/1.0"
    http_response_code:
      - HTTP_2XX
      - HTTP_3XX
      - HTTP_5XX
  EOT
}
#
variable "ansibleAviPbAbsent" {
  default     = "https://github.com/tacobayle/ansiblePbAviAbsent"
}
