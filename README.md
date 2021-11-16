

# Terraform Manifest

Terraform is currently used to create the AWS resources.  Currently these are:
- EC2 instance.
- Related ACL and other required entities.

To install Terraform (free): [Terraform Install Page](https://www.terraform.io/downloads.html)

In order for the AWS connection to work you can use environment variables.  In my case this looks like: 
 *export AWS_ACCESS_KEY_ID="[value-provided-by-aws]"*.
 *export AWS_SECRET_ACCESS_KEY="[value-provided-by-aws]"*.
 *export AWS_SESSION_TOKEN="[value-provided-by-aws]"*.

 Adapt the *aws_ssh_public_key* variable in the *aws-resources.tf* file to select the appropriate ssh public key file in the AWS region/account. 

 To create the actual resources, once the access keys are present, simply run terraform from the directory where the .tf files are located.  For me, this looks like: .
  - *terraform init* # this initiates the provider
  - *terraform plan* # just gives an overview of what will be deployed
  - *terraform apply* # creates the resources in AWS

# Ansible Playbook 

The provided playbook is used to install NGINX Plus on the newly-created EC2 instance.

Installing Ansible is explained here: [Installing Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html).
The NGINX Ansible Role is also needed to run the playbook in this collection.  To install the NGINX role refer to [Ansible Galaxy](https://galaxy.ansible.com/nginxinc/nginx).  
A license is necessary to install NGINX Plus.  In the Ansible playbook below, the files are to be placed in the *license/* directory.  Trial licenses are available from local F5/NGINX sales representatives, or through the [free trial site](https://www.nginx.com/free-trial-request/)

To run the ansible playbook:
- modify the inventory file *hosts* (in the sample, the host is called *ec2-instance*, with ip address *18.116.X.X*)
- Adapt the files to point to the proper keys and license information - this includes the *ansible_ssh_private_key_file* value,  
- run the ansible playbook: *ansible-playbook ./converge.yml -i ./hosts*

# NGINX Plus Configuration

Sample configurationis in the nginx_conf directory.  

## TLS termination and client-certificate authentication
Refer to [Enabling client certificate authentication for NGINX](https://support.f5.com/csp/article/K18050039).  

The *"cert"* directory, in this repository, contains a bash script with configuration files to create sample certificates and keys for testing and validation purposes only.  These can be used in the NGINX plus configuration and to validate client-certificate authentication.  A sample curl command for simple validation is: 
- upload the configuration in the nginx_conf directory in this repository.
- upload the *server.crt*, *server.key*, and *ca.crt* keys to the */etc/nginx/conf.d/* directory on the NGINX instance in AWS. (created above)
- from a local workstation test connectivity with: *curl -v --cert client.crt --key client.key https://[ip address of EC2 instance] -k* 

## Location mantra and configuration for conditional S3 Bucket routing
A sample configuration with 2 locations is provided as an example.  One will forward requests coming to *https://[ip address of EC2 instance]/pdf* to one of 2 S3 buckets.  Requests to *https://[ip address of EC2 instance]/png*, will be sent to the other S3 bucket. 

In the configuration file, sample buckets and values are used - they will need to be substituted before uploading and running the nginx instance. 

Values that will need to be substituted are the following: 
- resolver *[insert AWS DNS server IP address here]*
- proxy_pass *[insert S3 bucket HTTPS address]*


# To do: 
- local-exec to invoke the ansible playbook from within th terraform manifest
- parametrize as many things as possible
- be careful to not share keys and licenses on the internet
- automate uploading NGINX configuration and certificates (using Ansible)
- redundancy : 2 AZ - same region 2 NGINX instances with ELB/NLB configuration

