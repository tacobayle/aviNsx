# Ansible host file creation

resource "null_resource" "foo1" {

  provisioner "local-exec" {
    command = <<EOD
cat <<EOF > ${var.ansibleHostFile}
---
all:
  children:
    controller:
      hosts:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo2" {
  count = var.controller["count"]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
        ${vsphere_virtual_machine.controller[count.index].default_ip_address}:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo3" {
  depends_on = [null_resource.foo2]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
      vars:
        ansible_user: admin
        ansible_ssh_private_key_file: '~/.ssh/${basename(var.jump["private_key_path"])}'
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo4" {
#  depends_on = [null_resource.foo3]
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#    backend:
#      hosts:
#EOF
#EOD
#  }
#}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo5" {
#  depends_on = [null_resource.foo4]
#  count = length(var.backendIpsMgt)
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#        ${split("/", element(var.backendIpsMgt, count.index))[0]}:
#EOF
#EOD
#  }
#}

# Ansible hosts file creation (continuing)

#resource "null_resource" "foo6" {
#  depends_on = [null_resource.foo3]
#  provisioner "local-exec" {
#    command = <<EOD
#cat <<EOF >> ${var.ansibleHostFile}
#      vars:
#        ansible_user: admin
#        ansible_ssh_private_key_file: '~/.ssh/${basename(var.jump["private_key_path"])}'
#EOF
#EOD
#  }
#}

# Ansible host file creation (finishing)

resource "null_resource" "foo7" {
  depends_on = [null_resource.foo3]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
  vars:
    ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF
EOD
  }
}


data "template_file" "jumpbox_userdata" {
  template = file("${path.module}/userdata/jump.userdata")
  vars = {
    password      = var.jump["password"]
    pubkey        = file(var.jump["public_key_path"])
    aviSdkVersion = var.jump["aviSdkVersion"]
    ipMgmt  = var.jump["ipMgmt"]
    ip = split("/", var.jump["ipMgmt"])[0]
    defaultGwMgt = var.jump["defaultGwMgt"]
    dnsMain      = var.jump["dnsMain"]
    defaultGwMgt = var.jump["defaultGwMgt"]
    netplanFile = var.jump["netplanFile"]
  }
}
#
data "vsphere_virtual_machine" "jump" {
  name          = var.jump["template_name"]
  datacenter_id = data.vsphere_datacenter.dc.id
}
#
resource "vsphere_virtual_machine" "jump" {
  name             = var.jump["name"]
  #depends_on = [null_resource.foo6]
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path
  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  num_cpus = var.jump["cpu"]
  memory = var.jump["memory"]
  wait_for_guest_net_routable = var.jump["wait_for_guest_net_routable"]
  guest_id = data.vsphere_virtual_machine.jump.guest_id
  scsi_type = data.vsphere_virtual_machine.jump.scsi_type
  scsi_bus_sharing = data.vsphere_virtual_machine.jump.scsi_bus_sharing
  scsi_controller_count = data.vsphere_virtual_machine.jump.scsi_controller_scan_count

  disk {
    size             = var.jump["disk"]
    label            = "jump.lab_vmdk"
    eagerly_scrub    = data.vsphere_virtual_machine.jump.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.jump.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.jump.id
  }

  vapp {
    properties = {
     hostname    = "jump"
     password    = var.jump["password"]
     public-keys = file(var.jump["public_key_path"])
     user-data   = base64encode(data.template_file.jumpbox_userdata.rendered)
   }
 }

  connection {
   host        = split("/", var.jump["ipMgmt"])[0]
   type        = "ssh"
   agent       = false
   user        = "ubuntu"
   private_key = file(var.jump["private_key_path"])
  }

  provisioner "remote-exec" {
   inline      = [
     "while [ ! -f /tmp/cloudInitDone.log ]; do sleep 1; done"
   ]
  }

  provisioner "file" {
  source      = var.jump["private_key_path"]
  destination = "~/.ssh/${basename(var.jump["private_key_path"])}"
  }

  provisioner "file" {
  source      = var.ansibleDirectory
  destination = "~/ansible"
  }

  provisioner "file" {
  content      = <<EOF

controller:
  environment: ${var.controller["environment"]}
  username: ${var.avi_user}
  version: ${split("-", var.controller["version"])[0]}
  floatingIp: ${var.controller["floatingIp"]}
  count: ${var.controller["count"]}
  password: ${var.avi_password}

avi_systemconfiguration:
  global_tenant_config:
    se_in_provider_context: false
    tenant_access_to_provider_se: true
    tenant_vrf: false
  welcome_workflow_complete: true
  ntp_configuration:
    ntp_servers:
      - server:
          type: V4
          addr: ${var.controller["ntpMain"]}
  dns_configuration:
    search_domain: ''
    server_list:
      - type: V4
        addr: ${var.controller["dnsMain"]}
  email_configuration:
    from_email: test@avicontroller.net
    smtp_type: SMTP_LOCAL_HOST

nsx:
  username: ${var.nsx_user}
  password: ${var.nsx_password}
  server: ${var.nsx_server}

vcenter:
  username: ${var.vsphere_user}
  password: ${var.vsphere_password}
  server: ${var.vsphere_server}

avi_cloud:
  name: ${var.avi_cloud["name"]}
  vtype: ${var.avi_cloud["vtype"]}
  transportZone: ${var.avi_cloud["transportZone"]}
  tier1: ${var.avi_cloud["tier1"]}
  dhcp_enabled: ${var.avi_cloud["dhcp_enabled"]}
  network: ${var.avi_cloud["network"]}

serviceEngineGroup:
  - name: &segroup0 Default-Group
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 2
    buffer_se: 1
    extra_shared_config_memory: 0
    vcenter_folder: ${var.folder}
    vcpus_per_se: 2
    memory_per_se: 4096
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0
  - name: &segroup1 seGroupCpuAutoScale
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 1
    buffer_se: 2
    extra_shared_config_memory: 0
    vcenter_folder: ${var.folder}
    vcpus_per_se: 1
    memory_per_se: 2048
    disk_per_se: 25
    auto_rebalance: true
    auto_rebalance_interval: 30
    auto_rebalance_criteria:
    - SE_AUTO_REBALANCE_CPU
    realtime_se_metrics:
      enabled: true
      duration: 0
  - name: &segroup2 seGroupGslb
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 1
    buffer_se: 0
    extra_shared_config_memory: 2000
    vcenter_folder: ${var.folder}
    vcpus_per_se: 2
    memory_per_se: 8192
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0

domain:
  name: ${var.domain["name"]}

avi_network_vip:
  name: ${var.avi_network_vip["name"]}
  tier1: ${var.avi_network_vip["tier1"]}
  dhcp_enabled: ${var.avi_network_vip["dhcp_enabled"]}
  exclude_discovered_subnets: ${var.avi_network_vip["exclude_discovered_subnets"]}
  vcenter_dvs: ${var.avi_network_vip["vcenter_dvs"]}
  subnet:
    - prefix:
        mask: "${element(split("/", var.avi_network_vip["subnet"]),1)}"
        ip_addr:
          type: "${var.avi_network_vip["type"]}"
          addr: "${element(split("/", var.avi_network_vip["subnet"]),0)}"
      static_ranges:
        - begin:
            type: "${var.avi_network_vip["type"]}"
            addr: "${var.avi_network_vip["begin"]}"
          end:
            type: "${var.avi_network_vip["type"]}"
            addr: "${var.avi_network_vip["end"]}"

avi_network_backend:
  name: ${var.backend["network"]}
  dhcp_enabled: ${var.avi_network_backend["dhcp_enabled"]}
  exclude_discovered_subnets: ${var.avi_network_backend["exclude_discovered_subnets"]}
  vcenter_dvs: ${var.avi_network_backend["vcenter_dvs"]}
  subnet:
    - prefix:
        mask: "${element(split("/", var.avi_network_backend["subnet"]),1)}"
        ip_addr:
          type: "${var.avi_network_backend["type"]}"
          addr: "${element(split("/", var.avi_network_backend["subnet"]),0)}"

avi_servers:
  ${yamlencode(var.backendIps)}

avi_healthmonitor:
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

avi_pool:
  name: &pool0 pool1
  lb_algorithm: LB_ALGORITHM_ROUND_ROBIN
  health_monitor_refs: *hm0

avi_virtualservice:
  http:
    - name: &vs0 app1
      services:
        - port: 80
          enable_ssl: false
        - port: 443
          enable_ssl: true
      pool_ref: *pool0
      enable_rhi: false
    - name: &vs1 app2-se-cpu-auto-scale-out
      services:
        - port: 443
          enable_ssl: true
      pool_ref: pool1
      enable_rhi: false
      se_group_ref: *segroup1
  dns:
    - name: app3-dns
      services:
        - port: 53
    - name: app4-gslb
      services:
        - port: 53
      se_group_ref: *segroup2

EOF
  destination = "~/ansible/vars/fromTerraform.yml"
  }

  provisioner "remote-exec" {
    inline      = [
      "chmod 600 ~/.ssh/${basename(var.jump["private_key_path"])}",
      "cd ansible ; git clone https://github.com/tacobayle/aviConfigure ; ansible-playbook -i hosts aviConfigure/local.yml --extra-vars @vars/fromTerraform.yml",
    ]
  }

}
