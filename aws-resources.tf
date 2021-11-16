##Variables

variable "instance_type" {
  default = "t2.micro"
}

variable "aws_ssh_public_key" {
  default = "romain_ohio_nginx"
}

##Extract the ami name for the aws region in use:
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]


  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

##Resources 
###Security Group
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

    ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

###EC2 Instance
resource "aws_instance" "myec2" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  key_name      = var.aws_ssh_public_key
  security_groups = ["allow_tls"]


  tags = {
    owner       = "romain"
    environment = "test"
    name        = "romain-nginx"
  }
}
##Outputs - optional
output "s3_bucket_dns" {
  value = aws_s3_bucket.romain-customer-test-bucket.bucket_domain_name
}

output "ec2_public_ip" {
  value = aws_instance.myec2.public_ip
}

##Ansible hosts file creation to run the ansible playbook after the manifest is done
resource "local_file" "hosts" {
  content  = "ec2-instance ansible_host=${aws_instance.myec2.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=/home/ubuntu/.ssh/romain_ohio_nginx.pem ansible_become=true"
  filename = "/home/ubuntu/s3_nginx_service/hosts"
}