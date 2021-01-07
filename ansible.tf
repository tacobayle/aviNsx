
resource "null_resource" "foo" {
  depends_on = [vsphere_virtual_machine.jump]
  connection {
    host        = split("/", var.jump["ipCidr"])[0]
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
  environment: ${var.controller.environment}
  username: ${var.avi_user}
  version: ${split("-", basename(var.contentLibrary.files[0]))[1]}
  floatingIp: ${var.controller.floatingIp}
  count: ${var.controller.count}
  password: ${var.avi_password}

controllerPrivateIps:
${yamlencode(vsphere_virtual_machine.controller.*.default_ip_address)}

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
          addr: ${var.controller.ntpMain}
  dns_configuration:
    search_domain: ''
    server_list:
      - type: V4
        addr: ${var.controller.dnsMain}
  email_configuration:
    from_email: test@avicontroller.net
    smtp_type: SMTP_LOCAL_HOST

nsxt:
  username: ${var.nsx_user}
  password: ${var.nsx_password}
  server: ${var.nsx_server}
  name: ${var.avi_cloud.name}
  transportZone: ${var.avi_cloud.transportZone}
  tier1: ${var.avi_cloud.tier1}
  dhcp_enabled: ${var.avi_cloud.dhcp_enabled}
  network: ${var.avi_cloud.network}
  networkType: ${var.avi_cloud.networkType}
  networkRangeBegin: ${var.avi_cloud.networkRangeBegin}
  networkRangeEnd: ${var.avi_cloud.networkRangeEnd}
  networkVrf: ${var.avi_cloud.networkVrf}
  vcenterContentLibraryId: ${vsphere_content_library.libraryAviSe.id}
  obj_name_prefix: ${var.avi_cloud.obj_name_prefix}

vcenter:
  username: ${var.vsphere_user}
  password: ${var.vsphere_password}
  server: ${var.vsphere_server}

serviceEngineGroup:
  - name: &segroup0 Default-Group
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 2
    buffer_se: 1
    extra_shared_config_memory: 0
    vcenter_folder: ${var.vcenter.folderAvi}
    vcpus_per_se: 1
    memory_per_se: 2048
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0
  - name: &segroup1 seGroupCpuAutoScale
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 2
    buffer_se: 0
    extra_shared_config_memory: 0
    vcenter_folder: ${var.vcenter.folderAvi}
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
    vcenter_folder: ${var.vcenter.folderAvi}
    vcpus_per_se: 2
    memory_per_se: 8192
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0

domain:
  name: ${var.domain.name}

avi_network_vip:
  name: ${var.avi_network_vip.name}
  tier1: ${var.avi_network_vip.tier1}
  dhcp_enabled: ${var.avi_network_vip.dhcp_enabled}
  exclude_discovered_subnets: ${var.avi_network_vip.exclude_discovered_subnets}
  vcenter_dvs: ${var.avi_network_vip.vcenter_dvs}
  type: ${var.avi_network_vip.type}
  networkRangeBegin: ${var.avi_network_vip.networkRangeBegin}
  networkRangeEnd: ${var.avi_network_vip.networkRangeEnd}

avi_network_backend:
  name: ${var.backend["network"]}
  dhcp_enabled: ${var.avi_network_backend["dhcp_enabled"]}
  exclude_discovered_subnets: ${var.avi_network_backend["exclude_discovered_subnets"]}
  vcenter_dvs: ${var.avi_network_backend["vcenter_dvs"]}
  type: ${var.avi_network_backend["type"]}

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

avi_pool_nsxtGroup:
  - name: &pool1 pool2BasedOnNsxtGroup
    groupName: ${var.nsxtGroup["name"]}
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
      pool_ref: *pool0
      enable_rhi: false
      se_group_ref: *segroup1
    - name: &vs2 app3-nsxtGroupBased
      services:
        - port: 443
          enable_ssl: true
      pool_ref: *pool1
      enable_rhi: false
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
      "cd ~/ansible ; git clone ${var.ansible["aviConfigureUrl"]} --branch ${var.ansible["aviConfigureTag"]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml aviConfigure/local.yml --extra-vars @vars/fromTerraform.yml",
    ]
  }
}
