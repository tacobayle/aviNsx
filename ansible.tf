
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
    source      = var.ansible.directory
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
  from_email: ${var.controller.from_email}
  se_in_provider_context: ${var.controller.se_in_provider_context}
  tenant_access_to_provider_se: ${var.controller.tenant_access_to_provider_se}
  tenant_vrf: ${var.controller.tenant_vrf}
  aviCredsJsonFile: ${var.controller.aviCredsJsonFile}

controllerPrivateIps:
${yamlencode(vsphere_virtual_machine.controller.*.default_ip_address)}

ntpServers:
${yamlencode(var.controller.ntp.*)}

dnsServers:
${yamlencode(var.controller.dns.*)}

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
  vcenterContentLibrary: ${var.avi_cloud.vcenterContentLibrary}
  obj_name_prefix: ${var.avi_cloud.obj_name_prefix}

vcenter:
  username: ${var.vsphere_user}
  password: ${var.vsphere_password}
  server: ${var.vsphere_server}

domain:
  name: ${var.domain.name}

avi_servers:
${yamlencode(var.backendIps)}

avi_pool_nsxtGroup:
  - name: pool2BasedOnNsxtGroup
    id: ${nsxt_policy_group.backend.id}
    cloud_ref: ${var.avi_cloud.name}

EOF
    destination = var.ansible.yamlFile
  }

  provisioner "file" {
    content = <<EOF
{"serviceEngineGroup": ${jsonencode(var.serviceEngineGroup)}, "avi_virtualservice": ${jsonencode(var.avi_virtualservice)}, "avi_network_vip": ${jsonencode(var.avi_network_vip)}, "avi_network_backend": ${jsonencode(var.avi_network_backend)}, "avi_pool": ${jsonencode(var.avi_pool)}}
EOF
    destination = var.ansible.jsonFile
  }

  provisioner "remote-exec" {
    inline      = [
      "chmod 600 ~/.ssh/${basename(var.jump["private_key_path"])}",
      "cd ~/ansible ; git clone ${var.ansible.aviConfigureUrl} --branch ${var.ansible.aviConfigureTag} ; cd ${split("/", var.ansible.aviConfigureUrl)[4]} ; ansible-playbook -i /opt/ansible/inventory/inventory.vmware.yml local.yml --extra-vars @${var.ansible.jsonFile} --extra-vars @${var.ansible.yamlFile}",
    ]
  }
}

