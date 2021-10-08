// export PKR_VAR_aws_access_key=$YOURKEY
variable "aws_access_key" {
  type = string
}

// export PKR_VAR_aws_secret_key=$YOURSECRETKEY
variable "aws_secret_key" {
  type = string
}

locals {
  jenkins_ami_name = "build-agent-${ formatdate("YYYYMMDD-hhmmss-ZZZ", timestamp()) }"
  uuid = uuidv4()
}

source "amazon-ebs" "jenkins_agent" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  ami_name        = local.jenkins_ami_name
  ami_description = "Jenkins build agent"

  ssh_username  = "ubuntu"
  region        = "us-east-1"
  source_ami    = "ami-09e67e426f25ce0d7"
  instance_type = "t3.large"
  encrypt_boot  = true

#  launch_block_device_mappings {
#    device_name = "/dev/sda1"
#    volume_size = 50
#    volume_type = "gp2"
#
#    delete_on_termination = true
#  }

  vpc_filter {
    filters = {
      "tag:Purpose" : "build",
      "tag:Packer" : true
    }
  }

  subnet_filter {
    filters = {
      "tag:Purpose" : "build",
      "tag:Packer" : true,
      "tag:cpco.io/subnet/type" : "public"
    }
  }

  run_tags = {
    Name          = "PACKER_BUILD-${local.jenkins_ami_name}"
    UUID          = local.uuid
    Packer_Build  = "true"
  }


  tags = {
    Name          = local.jenkins_ami_name
    UUID          = local.uuid
    Packer_Image  = "true"
    OS_Version    = "Ubuntu-20.04"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }
}

build {
  sources = [
    "source.amazon-ebs.jenkins_agent"
  ]

  provisioner "file" {
    destination = "/tmp/"
    source      = "./scripts/setup.sh"
  }

  provisioner "shell" {
    inline = [
      "cd /tmp",
      "chmod +x ./setup.sh",
      "/tmp/setup.sh"
    ]
  }
}
