variable "vsphere_user" {}
variable "vsphere_password" {}

variable "nsx_user" {}
variable "nsx_password" {}

variable "nsx_vsphere_user" {}
variable "nsx_vsphere_password" {}

variable "avi_password" {}
variable "avi_username" {}

variable "vcenter" {
  type = map
  default = {
    server = "10.0.0.10"
    dc = "N1-DC"
    cluster = "N1-Cluster1"
    datastore = "vsanDatastore"
    resource_pool = "N1-Cluster1/Resources"
    folderApps = "Avi-Apps"
    folderAvi = "Avi-Controllers"
  }
}

variable "contentLibrary" {
  default = {
    name = "Content Library Build Avi"
    description = "Content Library Build Avi"
    files = ["/home/christoph/Downloads/controller-20.1.4-9087.ova", "/home/christoph/Downloads/bionic-server-cloudimg-amd64.ova"] # keep the avi image first and the ubuntu image in the second position // don't change the name of the Avi OVA file
  }
}

variable "networkMgt" {
  type = map
  default     = {
    name = "N1-T1_Segment-01_10.7.1.0-24"
    tier1 = "N1-T1_AVI"
    cidr = "10.7.1.0/24"
  }
}

variable "controller" {
  default = {
    cpu = 8
    memory = 24768
    disk = 128
    count = "1"
    floatingIp = "10.7.1.200"
    wait_for_guest_net_timeout = 2
    private_key_path = "~/.ssh/cloudKey"
    mgmt_ip = "10.7.1.201"
    mgmt_mask = "255.255.255.0"
    default_gw = "10.7.1.1"
    dns = ["172.18.0.15"]
    ntp = ["172.18.0.15"]
    environment = "VMWARE"
    from_email = "avicontroller@avidemo.fr"
    se_in_provider_context = "false"
    tenant_access_to_provider_se = "true"
    tenant_vrf = "false"
    aviCredsJsonFile = "~/.avicreds.json"
  }
}

variable "jump" {
  type = map
  default = {
    name = "jump"
    cpu = 2
    memory = 4096
    disk = 24
    public_key_path = "~/.ssh/id_rsa/ubuntu-bionic-18.04-cloudimg-template.key.pub"
    private_key_path = "~/.ssh/id_rsa/ubuntu-bionic-18.04-cloudimg-template.key"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    aviSdkVersion = "18.2.9"
    ipCidr = "10.7.1.210/24"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.7.1.1"
    dnsMain = "172.18.0.15"
    username = "ubuntu"
  }
}

variable "ansible" {
  type = map
  default = {
    aviPbAbsentUrl = "https://github.com/tacobayle/ansiblePbAviAbsent"
    aviPbAbsentTag = "v1.51"
    aviConfigureUrl = "https://github.com/tacobayle/aviConfigure"
    aviConfigureTag = "v4.27"
    version = "2.9.12"
    directory = "ansible"
  }
}

variable "backend" {
  default = {
    cpu = 1
    memory = 2048
    disk = 10
    network = "N1-T1_Segment-Backend_10.7.6.0-24"
    wait_for_guest_net_routable = "false"
    template_name = "ubuntu-bionic-18.04-cloudimg-template"
    netplanFile = "/etc/netplan/50-cloud-init.yaml"
    defaultGw = "10.7.6.1"
    url_demovip_server = "https://github.com/tacobayle/demovip_server"
    username = "ubuntu"
    dnsMain = "172.18.0.15"
    dnsSec = "10.206.8.131"
    subnetMask = "/24"
    nsxtGroup = {
      name = "n1-avi-backend"
      description = "Created by TF - For Avi Build"
      tag = "n1-avi-backend"
    }
  }
}

variable "backendIps" {
  type = list
  default = ["10.7.6.10", "10.7.6.11"]
}

variable "client" {
  type = map
  default = {
    cpu = 1
    memory = 2048
    disk = 10
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

variable "clientIps" {
  type = list
  default = ["10.7.4.10"]
}

variable "nsxt" {
  default = {
    name = "cloudNsxt"
    server = "10.0.0.20"
    dhcp_enabled = "false"
    obj_name_prefix = "AVINSXT"
    domains = [
      {
        name = "avi.altherr.info"
      }
    ]
    transport_zone = {
      name = "N1_TZ_nested_nsx-overlay"
    }
    tier1s = [
      {
        name     = "N1-T1_AVI"
        description = "Created by TF - For Avi Build"
        route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_LB_VIP"] # TIER1_LB_VIP needs to be tested - 20.1.3 TOI
        tier0 = "N1_T0"
      }
    ]
    management_network = {
      name = "N1-T1_Segment-Mgmt-10.7.3.0-24"
      tier1 = "N1-T1_AVI"
      cidr = "10.7.3.0/24"
      ipStartPool = "11"
      ipEndPool = "50"
      type = "V4"
      dhcp_enabled = "no"
      exclude_discovered_subnets = "true"
      vcenter_dvs = "true"
    }
    network_vip = {
      name = "N1-T1_Segment-VIP-A_10.7.4.0-24"
      tier1 = "N1-T1_AVI"
      cidr = "10.7.4.0/24"
      type = "V4"
      ipStartPool = "11"
      ipEndPool = "50"
      exclude_discovered_subnets = "true"
      vcenter_dvs = "true"
      dhcp_enabled = "false"
      gateway = "1"
    }
    network_backend = {
      name = "N1-T1_Segment-Backend_10.7.6.0-24"
      tier1 = "N1-T1_AVI"
      cidr = "10.7.6.0/24"
    }
    vcenter = {
      server = "10.0.0.10"
      name = "vcenter-server-A"
      content_library = {
        name = "Avi SE Content Library"
        description = "TF built - Avi SE Content Library"
      }
      serviceEngineGroup = [
        {
          name = "Default-Group"
          ha_mode = "HA_MODE_SHARED"
          min_scaleout_per_vs = 2
          buffer_se = 1
          extra_shared_config_memory = 0
          vcenter_folder = "Avi-SE-Default-Group"
          vcpus_per_se = 1
          memory_per_se = 2048
          disk_per_se = 25
          realtime_se_metrics = {
            enabled = true
            duration = 0
          }
        },
        {
          name = "seGroupCpuAutoScale"
          ha_mode = "HA_MODE_SHARED"
          min_scaleout_per_vs = 1
          buffer_se = 0
          extra_shared_config_memory = 0
          vcenter_folder = "Avi-SE-Autoscale"
          vcpus_per_se = 1
          memory_per_se = 1024
          disk_per_se = 25
          auto_rebalance = true
          auto_rebalance_interval = 30
          auto_rebalance_criteria = [
            "SE_AUTO_REBALANCE_CPU"
          ]
          realtime_se_metrics = {
            enabled = true
            duration = 0
          }
        },
        {
          name = "seGroupGslb"
          ha_mode = "HA_MODE_SHARED"
          min_scaleout_per_vs = 1
          buffer_se = 0
          extra_shared_config_memory = 2000
          vcenter_folder = "Avi-SE-GSLB"
          vcpus_per_se = 2
          memory_per_se = 8192
          disk_per_se = 25
          realtime_se_metrics = {
            enabled = true
            duration = 0
          }
        }
      ]
    }
    httppolicyset = [
      {
        name = "http-request-policy-app3-content-switching-nsxt"
        http_request_policy = {
          rules = [
            {
              name = "Rule 1"
              match = {
                path = {
                  match_criteria = "CONTAINS"
                  match_str = ["hello", "world"]
                }
              }
              rewrite_url_action = {
                path = {
                  type = "URI_PARAM_TYPE_TOKENIZED"
                  tokens = [
                    {
                      type = "URI_TOKEN_TYPE_STRING"
                      str_value = "index.html"
                    }
                  ]
                }
                query = {
                  keep_query = true
                }
              }
              switching_action = {
                action = "HTTP_SWITCHING_SELECT_POOL"
                status_code = "HTTP_LOCAL_RESPONSE_STATUS_CODE_200"
                pool_ref = "/api/pool?name=pool1-hello-nsxt"
              }
            },
            {
              name = "Rule 2"
              match = {
                path = {
                  match_criteria = "CONTAINS"
                  match_str = ["avi"]
                }
              }
              rewrite_url_action = {
                path = {
                  type = "URI_PARAM_TYPE_TOKENIZED"
                  tokens = [
                    {
                      type = "URI_TOKEN_TYPE_STRING"
                      str_value = ""
                    }
                  ]
                }
                query = {
                  keep_query = true
                }
              }
              switching_action = {
                action = "HTTP_SWITCHING_SELECT_POOL"
                status_code = "HTTP_LOCAL_RESPONSE_STATUS_CODE_200"
                pool_ref = "/api/pool?name=pool2-avi-nsxt"
              }
            },
          ]
        }
      }
    ]
    pools = [
      {
        name = "pool1-hello-nsxt"
        lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
      },
      {
        name = "pool2-avi-nsxt"
        application_persistence_profile_ref = "System-Persistence-Client-IP"
        default_server_port = 8080
      }
    ]
    pool_nsxt_group = {
      name = "pool3BasedOnNsxtGroup"
      lb_algorithm = "LB_ALGORITHM_ROUND_ROBIN"
      nsxt_group_name = "n1-avi-backend"
    }
    virtualservices = {
      http = [
        {
          name = "app1-hello-world-nsxt"
          pool_ref = "pool1-hello-nsxt"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
        {
          name = "app2-avi-nsxt"
          pool_ref = "pool2-avi-nsxt"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
        {
          name = "app3-content-switching-nsxt"
          pool_ref = "pool2-avi-nsxt"
          http_policies = [
            {
              http_policy_set_ref = "/api/httppolicyset?name=http-request-policy-app3-content-switching-nsxt"
              index = 11
            }
          ]
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
        {
          name = "app4-se-cpu-auto-scale-nsxt"
          pool_ref = "pool1-hello-nsxt"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
          se_group_ref: "seGroupCpuAutoScale"
        },
        {
          name = "app5-nsxtGroupBased"
          pool_ref = "pool3BasedOnNsxtGroup"
          services: [
            {
              port = 80
              enable_ssl = "false"
            },
            {
              port = 443
              enable_ssl = "true"
            }
          ]
        },
      ]
      dns = [
        {
          name = "app6-dns"
          services: [
            {
              port = 53
            }
          ]
        },
        {
          name = "app7-gslb"
          services: [
            {
              port = 53
            }
          ]
          se_group_ref: "seGroupGslb"
        }
      ]
    }
  }
}