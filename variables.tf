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
    wait_for_guest_net_timeout = 2
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
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    network = "vxw-dvs-34-virtualwire-116-sid-6120115-wdc-06-vc12-avi-dev112"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    defaultGwMgt = "10.206.112.1"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    dnsMain = "10.206.8.130"
    dnsSec = "10.206.8.131"
  }
}
#
variable "client" {
  type = map
  default = {
    cpu = 2
    memory = 4096
    disk = 20
    password = "Avi_2020"
    network = "vxw-dvs-34-virtualwire-120-sid-6120119-wdc-06-vc12-avi-dev116"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    defaultGwMgt = "10.206.112.1"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    dnsMain = "10.206.8.130"
    dnsSec = "10.206.8.131"
  }
}
#
variable "backendIpsMgt" {
  type = list
  default = ["10.206.112.120/22", "10.206.112.121/22", "10.206.112.123/22"]
}
#
variable "clientIpsMgt" {
  type = list
  default = ["10.206.112.114/22", "10.206.112.124/22"]
}
#
### Ansible variables
#
variable "ansibleHostFile" {
  default = "ansible/hosts"
}
#
variable "ansibleDirectory" {
  default = "ansible"
}
#
variable "aviAdminUser" {
  default = "admin"
}
#
variable "aviPassword" {
  default = "Avi_2020"
}
#
# please keep the blank line after default = <<EOT
#
variable "aviUser" {
  default = <<EOT

  - name: ansible
    is_superuser: true
    user_profile_ref: "/api/useraccountprofile?name=Default-User-Account-Profile"
    is_active: true
    default_tenant_ref: "/api/tenant?name=admin"
    access:
      - role_ref: "/api/role?name=System-Admin"
        tenant_ref: "/api/tenant/admin#admin"
      - all_tenants: true
        role_ref: "/api/role?name=System-Admin"
    credsJsonFile: ../aviLscCloud/vars/creds.json
  - name: terraform
    is_superuser: true
    user_profile_ref: "/api/useraccountprofile?name=Default-User-Account-Profile"
    is_active: true
    default_tenant_ref: "/api/tenant?name=admin"
    access:
      - role_ref: "/api/role?name=System-Admin"
        tenant_ref: "/api/tenant/admin#admin"
      - all_tenants: true
        role_ref: "/api/role?name=System-Admin"
    credsJsonFile: ../../terraform/aviVs/creds.tfvars.json
  - name: python
    is_superuser: true
    user_profile_ref: "/api/useraccountprofile?name=Default-User-Account-Profile"
    is_active: true
    default_tenant_ref: "/api/tenant?name=admin"
    access:
      - role_ref: "/api/role?name=System-Admin"
        tenant_ref: "/api/tenant/admin#admin"
      - all_tenants: true
        role_ref: "/api/role?name=System-Admin"
    credsJsonFile: ../../python/aviVs/creds.json
  - name: vrovra
    is_superuser: true
    user_profile_ref: "/api/useraccountprofile?name=Default-User-Account-Profile"
    is_active: true
    default_tenant_ref: "/api/tenant?name=admin"
    access:
      - role_ref: "/api/role?name=System-Admin"
        tenant_ref: "/api/tenant/admin#admin"
      - all_tenants: true
        role_ref: "/api/role?name=System-Admin"
  EOT
}
#
# please keep the blank line after default = <<EOT
#
variable "avi_systemconfiguration" {
  default = <<EOT

  global_tenant_config:
    se_in_provider_context: false
    tenant_access_to_provider_se: true
    tenant_vrf: false
  welcome_workflow_complete: true
  ntp_configuration:
    ntp_servers:
      - server:
          type: V4
          addr: 192.168.10.3
  dns_configuration:
    search_domain: ''
    server_list:
      - type: V4
        addr: 8.8.8.8
      - type: V4
        addr: 4.4.4.4
  email_configuration:
    from_email: test@avicontroller.net
    smtp_type: SMTP_LOCAL_HOST
  EOT
}
#
variable "avi_cloud" {
  type = map
  default = {
    name = "CloudVmw"
    vtype = "CLOUD_VCENTER"
    network = "vxw-dvs-34-virtualwire-3-sid-6120002-wdc-06-vc12-avi-mgmt"
  }
}
#
variable "avi_network_vip" {
  type = map
  default = {
    name = "vxw-dvs-34-virtualwire-120-sid-6120119-wdc-06-vc12-avi-dev116"
    subnet = "100.64.133.0/24"
    begin = "100.64.133.50"
    end = "100.64.133.99"
    type = "V4"
  }
}
#
variable "avi_network_backend" {
  type = map
  default = {
    subnet = "100.64.129.0/24"
    type = "V4"
    dhcp = "yes"
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
variable "dns" {
  type = map
  default = {
    name = "dns-avi"
    domainName = "vmw.avidemo.fr"
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
