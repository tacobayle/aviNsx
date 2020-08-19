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

resource "null_resource" "foo4" {
  depends_on = [null_resource.foo3]
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
    backend:
      hosts:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo5" {
  depends_on = [null_resource.foo4]
  count = length(var.backendIpsMgt)
  provisioner "local-exec" {
    command = <<EOD
cat <<EOF >> ${var.ansibleHostFile}
        ${split("/", element(var.backendIpsMgt, count.index))[0]}:
EOF
EOD
  }
}

# Ansible hosts file creation (continuing)

resource "null_resource" "foo6" {
  depends_on = [null_resource.foo5]
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

# Ansible host file creation (finishing)

resource "null_resource" "foo7" {
  depends_on = [null_resource.foo6]
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
    avisdkVersion = var.jump["avisdkVersion"]
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
  depends_on = [null_resource.foo6]
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  folder           = vsphere_folder.folder.path
  network_interface {
                      network_id = data.vsphere_network.networkMgt.id
  }

  num_cpus = var.jump["cpu"]
  memory = var.jump["memory"]
  wait_for_guest_net_timeout = var.jump["wait_for_guest_net_timeout"]
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
   host        = self.default_ip_address
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
aviVersion: ${var.controller["version"]}
aviCluster: ${var.controller["count"]}
aviAdminUser: ${var.aviAdminUser}
aviPassword: ${var.aviPassword}
aviUser: ${var.aviUser}
floatingIp: ${var.controller["floatingIp"]}
avi_systemconfiguration: ${var.avi_systemconfiguration}
avi_cloud:
  name: ${var.avi_cloud["name"]}
  vtype: ${var.avi_cloud["vtype"]}
  network: ${var.avi_cloud["network"]}
  dhcp_enabled: true
  vcenter_configuration:
    username: ${var.vsphere_user}
    password: ${var.vsphere_password}
    vcenter_url: ${var.vsphere_server}
    privilege: WRITE_ACCESS
    datacenter: ${var.dc}
    management_network: "/api/vimgrnwruntime/?name=${var.avi_cloud["network"]}"
dns:
  name: ${var.dns["name"]}
  domain:
    name: ${var.dns["domainName"]}
avi_network_vip:
  name: ${var.avi_network_vip["name"]}
  dhcp_enabled: no
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
  dhcp_enabled: ${var.avi_network_backend["dhcp"]}
  subnet:
    - prefix:
        mask: "${element(split("/", var.avi_network_backend["subnet"]),1)}"
        ip_addr:
          type: "${var.avi_network_backend["type"]}"
          addr: "${element(split("/", var.avi_network_backend["subnet"]),0)}"
ipam:
  name: ${var.ipam["name"]}
serviceEngineGroup:
  - name: Default-Group
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 2
    buffer_se: 1
    extra_shared_config_memory: 0
    #vcenter_folder: ${var.folder}/se
    vcenter_folder: ${var.folder}
    vcpus_per_se: 2
    memory_per_se: 4096
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0
  - name: seGroupGslb
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 1
    buffer_se: 0
    extra_shared_config_memory: 2000
    #vcenter_folder: ${var.folder}/se
    vcenter_folder: ${var.folder}
    vcpus_per_se: 2
    memory_per_se: 8192
    disk_per_se: 25
    realtime_se_metrics:
      enabled: true
      duration: 0
  - name: &segroup2 seGroupCpuAutoScale
    ha_mode: HA_MODE_SHARED
    min_scaleout_per_vs: 1
    buffer_se: 2
    extra_shared_config_memory: 0
    #vcenter_folder: ${var.folder}/se
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
avi_healthmonitor: ${var.avi_healthmonitor}
avi_pool:
  name: &pool0 pool1
  lb_algorithm: LB_ALGORITHM_ROUND_ROBIN
  health_monitor_refs: *hm0
avi_servers:
${yamlencode(vsphere_virtual_machine.backend.*.guest_ip_addresses)}
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
      se_group_ref: *segroup2

EOF
  destination = "~/ansible/vars/fromTerraform.yml"
  }

  provisioner "remote-exec" {
    inline      = [
      "chmod 600 ~/.ssh/${basename(var.jump["private_key_path"])}",
      "ansible-playbook -i ~/ansible/hosts ~/ansible/main.yml",
    ]
  }

}
