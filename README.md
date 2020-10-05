# aviNsx

## Goals
Spin up a full VMware/Avi environment (through Terraform) with V-center and NSX-T integration

## Prerequisites:
- Make sure terraform in installed in the orchestrator VM
- Make sure VMware credential/details are configured as environment variable for Vcenter:
```
TF_VAR_vsphere_user=******
TF_VAR_vsphere_server=******
TF_VAR_vsphere_password=******
```
- Make sure VMware credential/details are configured as environment variable for NSXT:
```
TF_VAR_nsx_user=******
TF_VAR_nsx_password=******
TF_VAR_nsx_server=******
```
- Make sure the content library has been configured on V-center
- Make sure you have an avi_network_vip segment configured on NSXT
- Make sure you have an avi_network_backend segment configured on NSXT
- Make sure you have an avi_network_management segment configured on NSXT
- Make sure an NSXT group has been created: with DFW rules associated and tag associated with it

## Environment:

Terraform Plan has/have been tested against:

### terraform

```
Terraform v0.13.1
+ provider registry.terraform.io/hashicorp/null v2.1.2
+ provider registry.terraform.io/hashicorp/template v2.1.2
+ provider registry.terraform.io/hashicorp/vsphere v1.24.0
+ provider registry.terraform.io/terraform-providers/nsxt v3.0.1
Your version of Terraform is out of date! The latest version is 0.13.2. You can update by downloading from https://www.terraform.io/downloads.html
```

### Avi version
```
Avi 20.1.1 with one controller node
```

### V-center/ESXi version:
```
vCSA - 7.0.0 Build 16749670
ESXi host - 7.0.0 Build 16324942
```

### Avi Configure (anisble playbook) tag:
```
```

### Avi Destroy (anisble playbook) tag:
```
```


### NSXT version:
```
NSX 3.0.1.1
```

## Input/Parameters:

- All the paramaters/variables are stored in variables.tf

## Use the the terraform plan to:
- Create a new folder
- Spin up n Avi Controller - count based on var.controller["count"]
- Spin up n backend VM(s) - count based on the length of var.backendIps - Assign  NSXT tag
- Spin up n client server(s) - count based on the length of var.clientIps - while true ; do ab -n 1000 -c 1000 https://a.b.c.d/ ; done
- Spin up a jump server with ansible intalled - userdata to install packages - VMware dynamic inventory enabled/configured
- Create a yaml variable file - in the jump server
- Call ansible to do the Avi configuration (git clone)

## Run the terraform:
```
cd ..  ; rm -fr aviNsx ; git clone https://github.com/tacobayle/aviNsx ; cd aviNsx ;  terraform 0.13upgrade .
terraform init ; terraform apply -auto-approve ;
# the terraform will output the command to destroy the environment.
```

## to be done:
- Input a correct value for aviPbAbsentTag
