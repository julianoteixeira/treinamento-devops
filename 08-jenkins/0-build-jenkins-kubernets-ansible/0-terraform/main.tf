provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "jenkins" {
  ami                         = "ami-0d6806446a46f9b9c"
  instance_type               = "t2.large"
  subnet_id                   = "subnet-01aca3d2f7d561284"
  associate_public_ip_address = true
  key_name                    = "key-par-devops"
  tags = {
    Name = "jenkins"
  }
  vpc_security_group_ids = ["${aws_security_group.jenkins.id}"]
}

resource "aws_security_group" "jenkins" {
  name        = "acessos_jenkins"
  description = "acessos_jenkins inbound traffic"
  vpc_id      = "vpc-0a0eeef20f67dfb8d"
  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
    {
      description      = "SSH from VPC"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null,
      security_groups : null,
      self : null
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"],
      prefix_list_ids  = null,
      security_groups : null,
      self : null,
      description : "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "jenkins-lab"
  }
}

# terraform refresh para mostrar o ssh
output "jenkins" {
  value = [
    "jenkins",
    "id: ${aws_instance.jenkins.id}",
    "private: ${aws_instance.jenkins.private_ip}",
    "public: ${aws_instance.jenkins.public_ip}",
    "public_dns: ${aws_instance.jenkins.public_dns}",
    "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.jenkins.public_dns}"
  ]
}
