# aviVmw

## Goals
Spin up a full VMware/Avi environment (through Terraform and Ansible) with V-center integration without NSX-T integration

## Prerequisites:
1. Make sure terraform in installed in the orchestrator VM
2. Make sure VMware credential/details are configured as environment variable:
```
TF_VAR_vsphere_user=******
TF_VAR_vsphere_server=******
TF_VAR_vsphere_password=******

```

## Environment:

Terraform Plan and Ansible Playbook(s) has/have been tested against:

### terraform

```
avi@ansible:~$ terraform -v
nic@jump:~/aviVmw$ terraform -v
Terraform v0.12.29
+ provider.null v2.1.2
+ provider.template v2.1.2
+ provider.vsphere v1.15.0
nic@jump:~/aviVmw$
```

### Avi version

```
Avi 20.1.1 with one controller node
Avi 20.1.1 with three controller nodes cluster
```

### V-center version:


## Input/Parameters:

1. All the paramaters/variables are stored in variables.tf

## Use the the terraform script to:
1. Create a new folder
2. Spin up n Avi Controller
3. Spin up n backend VM(s) - (count based on the length of var.backendIpsMgt)
4. Spin up n client server(s) - (count based on the length of var.clientIpsMgt) - while true ; do ab -n 1000 -c 1000 https://100.64.133.51/ ; done 
5. Create an ansible hosts file including a group for avi controller(s), a group for backend server(s)
6. Spin up a jump server with ansible intalled - userdata to install package
7. All the following tasks are done through Ansible via the jump VM:
- Bootsrap the controller (with cluster config with Virtual IP - if 3 Avi controller deployed)
- Create accounts with auto-generated password for automation accounts
- Configure Avi Controller System config.
- Configure VMware Cloud with update of the Management network
- Configure DNS/IPAM based on Avi
- Configure SE group (Default-Group, seGroupGslb, seGroupCpuAutoScale)
- Configure health monitor, pool, vsvip, virtualservice (app1, app2-se-cpu-auto-scale-out)

## Run the terraform:
```
terraform apply -auto-approve
# the terraform will output the command to destroy the environment.
```

## Improvement:

### future devlopment:

- autoscaling
- GSLB
