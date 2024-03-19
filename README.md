## MediaWiki Readme.md

### MediaWiki application here is being installed using Terraform and Ansible in Azure Cloud.


#### Steps
1. main.tf -> Logic for provisioning Azure resources.
2. variables.tf -> Variables are defined in this file.
3. terraform.tfvars -> file to update your resource values\names.
4. customdata.tpl -> Template file to provision required resources to run ansible playbook.


Run the following commands to provision resources.

```
  terraform init
  terraform plan
  terraform apply
```

Once virtual machine is provisioned, log into it using the pem file/private key.
There is a shell script which is customdata.tpl consists of responsible to update the os and install required packages such as ansible, python etc.

After the installation completes, the residing ansible playbooks are run to download, extract and publish the MediaWiki web application.