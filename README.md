# packer-ansible-ec2
Automated image builds for AWS EC2

# Overview

On occasion, it becomes necessary to prebuild custom golden images for utilization with AWS EC2. This project aims to ease the burden of creating these images via automation. [Packer](https://www.packer.io/) and [Ansible](https://github.com/ansible/ansible) are utilized together, with Packer employing the [the EBS AMI builder](https://www.packer.io/plugins/builders/amazon/ebs). This builder constructs a golden AMI by first launching an EC2 instance from an initial source AMI, then provisioning and customizing that running instance via user-provided automation (Ansible in the case of this project), and finally shutting the instance down and creating a golden AMI from the quiesced instance storage. This is all done in the AWS account specified via credentials. The builder will create temporary keypairs, security group rules, etc. that provide temporary access to the instance while the image is being created/customized.

Requirements
------------

* Linux or MacOS system, with `git` and `python` available
* AWS account with existing VPC and subnet within the VPC. The VPC subnet needs to be accessible by your local system, so a publicly accessible subnet at the least should be utilized. Temporary keypairs and security group rules will secure the communication stream.
* Packer from https://www.packer.io/downloads
* Ansible installed via the package manager of choice for the given OS/distribution or via `python\pip` module install (virtualenv/venv recommended)

Configuration
------------
1) Clone this repo to local system
2) *cd* to the `packer-ansible-ec2` directory and then `git checkout` the build branch of interest e.g. `git checkout satellite-6.11`
3) Either edit `packer-build.json` directly or copy to new json file and edit new file  
<tab>modify the following variables:
* `ami_name`: "Satellite 6.11 {{isotime `2006-01-02-150405`}}" (default AMI name will include time stamp of build launch)
* `aws_region`: EC2 region where temporary build instance will run, ie `us-east-1`
* `vpc_id`: VPC ID that exists in the region specified above
* `subnet_id`: Subnet ID that exists within above VPC
* `red_hat_activation_key`: Red Hat Activation key that contains valid subscriptions for products being installed e.g. Red Hat Satellite
* `red_hat_org_id`: Red Hat organization ID for account that owns above activation key
* `ah_api_token`: [Red Hat Automation Hub API token](https://console.redhat.com/ansible/automation-hub/token)
* `controller_manifest_url`: Red Hat product subscription manifest location accessible by the temporary EC2 builder instance (if required by product installation and/or configuration). Generate manifest [here](https://access.redhat.com/management/subscription_allocations) and then move to specified URL location

EBS AMI Build
-------------
packer build -machine-readable packer-build.json | tee build_artifact-$(date +%Y-%m-%d.%H%M).txt