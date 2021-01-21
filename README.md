# aviNsx

## Goal
Spin up a full VMware/Avi environment (through Terraform) with V-center and NSX-T integration

## Prerequisites:
- Terraform installed in the orchestrator VM
- credential/details configured as environment variables for vCenter:
```
TF_VAR_vsphere_user=******
TF_VAR_vsphere_password=******
```
- credential/details configured as environment variables for NSX-T:
```
TF_VAR_nsx_user=******
TF_VAR_nsx_password=******
```
- credential/details configured as environment variables for the V-center(s) associated to NSX-T in the AVI cloud:
```
TF_VAR_nsx_vsphere_user=******
TF_VAR_nsx_vsphere_password=******
```
- credential/details configured as environment variables for Avi:
```
TF_VAR_avi_username=******
TF_VAR_avi_password=******
```
- tier0 router deployed (connected to the physical network) and the name of the tier 0 router needs to be configured in var.tier1.tier0
- following files available in your TF VM and need to be configured in var.contentLibrary.files:
```
files = ["/home/ubuntu/Downloads/controller-20.1.3-9085.ova", "/home/ubuntu/Downloads/bionic-server-cloudimg-amd64.ova"] # keep the avi image first and the ubuntu image in the second position // don't change the name of the Avi OVA file
```
- ssh key defined and configured for:
```
var.jump.public_key_path
var.jump.private_key_path
```
- Internet access is required to install Ansible and other stuff

## Environment:

Terraform Plan has/have been tested against:

### terraform

```
Terraform v0.13.5
+ provider registry.terraform.io/hashicorp/null v2.1.2
+ provider registry.terraform.io/hashicorp/template v2.1.2
+ provider registry.terraform.io/hashicorp/vsphere v1.24.0
+ provider registry.terraform.io/terraform-providers/nsxt v3.0.1
Your version of Terraform is out of date! The latest version is 0.13.2. You can update by downloading from https://www.terraform.io/downloads.html
```

### Avi version
```
Avi 20.1.3 with one controller node
```

### vCenter version:
```
Version:  7.0.1-17327586
```

### ESXi host version:

```
VMware ESXi, 7.0.1, 17325551
```

### NSX-T version:
```
Version 3.1.0.0.0.17107167
```

## Input/Parameters:

- All the paramaters/variables are stored in variables.tf

## Use the the terraform plan to:
- Create new folders in vSphere
- Create segments in NSX-T (var.networkMgt, var.avi_network_vip, var.avi_network_backend, var.avi_cloud.network)
- Create NSX-T group for backend servers (var.backend.nsxtGroup) with a specific tag for this group
- Spin up n Avi Controller - count based on var.controller.count
- Spin up n backend VM(s) - count based on the length of var.backendIps - Assign NSX-T tag to assign the VMs in the group 
- Spin up n client server(s) - count based on the length of var.clientIps - while true ; do ab -n 1000 -c 1000 https://a.b.c.d/ ; done
- Spin up a jump server with ansible intalled - userdata to install packages - VMware dynamic inventory enabled/configured
- Create a yaml variable file - in the jump server
- Call ansible to do the Avi configuration (git clone)

## Run the terraform:
```
cd ~  ; rm -fr aviNsx ; git clone https://github.com/tacobayle/aviNsx ; cd aviNsx ;  terraform 0.13upgrade .
terraform init ; terraform apply -auto-approve ;
# the terraform will output the command to destroy the environment.
```
