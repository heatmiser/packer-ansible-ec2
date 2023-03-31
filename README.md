# packer-ansible-ec2

Automated image builds for AWS EC2

# Overview

This project aims to simplify the process of **building golden images on AWS** through **automation**.

[Packer](https://www.packer.io) and [Ansible](https://github.com/ansible/ansible) are used in combination, with `Packer` utilizing the [the EBS AMI builder](https://www.packer.io/plugins/builders/amazon/ebs) to construct a golden AMI. This involves:  

* Provisoning an EC2 instance from an initial source AMI
* Configuring it through user-provided automation (in this project's case, Ansible)
* Imaging a golden AMI from the instance storage after powering the instance down

All of this is carried out within the AWS account specified by the user's credentials by supplying the environment variables:

* `AWS_ACCESS_KEY_ID=AKID.....` 
* `AWS_SECRET_ACCESS_KEY=Abcid9.....`

The builder generates temporary keypairs, security group rules, and other resources that offer temporary access to the instance while the image is being created or customized.

Requirements
------------

* Linux or MacOS system, with `git` and `python` and `bash` installed on the machine you are using to run the build script and packer. All other software packages will be installed as needed on the image build via the bootstrap and packer, and Ansible scripts.
* AWS account
  * account `AWS access key ID`
  * account `AWS secret access key`
  * existing AWS infrastructure
    * exiting `vpc`
    * existing **publically accessable** `subnet` within the `vpc`
    * **NOTE**: If you wish to create the AWS infrastructure as code, then you can use this project to build our your AWS infrastructure quickly using IaC using Ansible:
  
            Smart Management AWS: https://github.com/rclements-redhat/smart-management-aws

  * Packer from https://www.packer.io/downloads
  * Note: Temporary keypairs and security group rules will secure the communication stream
  
CONFIGURE
------------

1) Clone this repo to local system
   
   `git clone https://github.com/heatmiser/packer-ansible-ec2`

2) Change to the `packer-ansible-ec2` directory and perform a ``git checkout`` to build the branch of interest
   
   `cd packer-ansible-ec2 && git checkout satellite-6.12`
   
3) Rename the `packer-build-template.json` to `packer-build.json` to make a company of the template

    `cp --no-clobber packer-build-template.json packer-build.json`

4) Edit the `packer-build.json` settings file and replace the settings so that it works for your implementation. See below.

    `vim packer-build.json || vi packer-build.json || nano packer-build.json`

    Modify the following variables:

    * `ami_name`
 
        Default: `Satellite 6.12 {{`\``isotime 2006-01-02-150405`\``}}`  

        Name of the ami once it is completed  
        
    * `aws_region`

        Default: `us-east-1`  

        EC2 region where temporary build instance will run  

    * `vpc_id`

        Placeholder: `_YOUR_AWS_VPC_ID_`  

        VPC ID that exists in the region specified above  

    * `subnet_id`

        Placeholder: `_YOUR_AWS_PUBLIC_SUBNET_ID_`  

        **Publically** accessible subnet ID that exists within above VPC  

    * `red_hat_activation_key`
  
        Placeholder: `_YOUR_RED_HAT_ACT_KEY_`  
        
        Red Hat Activation key that contains valid subscriptions for products being installed e.g. Red Hat Satellite  


    * `red_hat_org_id`

        Placeholder: `_YOUR_RED_HAT_ORG_ID_` 

        Red Hat organization ID for account that owns above activation key  

    * `ah_api_token`
  
        Instructions here: [Red Hat Automation Hub API token](https://console.redhat.com/ansible/automation-hub/token)

     * `download_program`: Can be either:  

        Default: `curl`

        * `s3` - ensure `satellite_manifest_url` is a valid `s3://` address
        * `curl` - ensure `satellite_manifest_url` is a valid `http://` or `https://` address
        * If anything but `s3`, it defaults to `curl`.
  
    * `satellite_manifest_url`

        Placeholder: `_HTTP_OR_S3_ADDRESS_`  

        * Red Hat product subscription manifest location accessible by the temporary EC2 builder instance (if required by product installation and/or configuration)  
        * Generate manifest [here](https://access.redhat.com/management/subscription_allocations) and then move to a publically `http/s` URL or private `s3` location. See `download_program` option above.
        * More information about the entire manifest process [here](https://www.redhat.com/en/blog/how-create-and-use-red-hat-satellite-manifest)  

With the above steps completed, you may move on to the EBS AMI Build section below.

BUILD: EBS AMI Build
-------------
Use either method:

**Option 1: Build Script (_recommended_)**

1) Change into the main repo directory

    `cd packer-ansible-ec2`

2) Run the `./build.sh` script. It will do prechecks and use `nohup` to ensure the build continues if you get disconnected. It will also monitor the fork using `tail -f log`

    `./build.sh`

**Option 2: Ad-hoc (if you disconnect the build will interrupt)**
  
1) Change into the main repo directory
   
    `cd packer-ansible-ec2`


2) Run the packer build on the command line.
  
    `packer build -machine-readable packer-build.json | tee build_artifact-$(date +%Y-%m-%d.%H%M).txt`
    
    You are living dangerously with this option. If you get disconnected, the build will fail. No prechecks with this method either.
