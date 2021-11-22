provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "k8s_proxy" {
  ami           = "ami-0d6806446a46f9b9c"
  subnet_id = "subnet-01aca3d2f7d561284"
  instance_type = "t2.medium"
  key_name      = "key-par-devops"
  associate_public_ip_address = true
  tags = {
    Name = "k8s-haproxy"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 32
  }
  vpc_security_group_ids = [aws_security_group.acessos_haproxy.id]
}

resource "aws_instance" "k8s_masters" {
  ami           = "ami-0d6806446a46f9b9c"
  associate_public_ip_address = true
  subnet_id = "subnet-01aca3d2f7d561284"
  instance_type = "t2.large"
  key_name      = "key-par-devops"
  count         = 3
  tags = {
    Name = "k8s-master-${count.index}"
  }
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 32
  }
  vpc_security_group_ids = [aws_security_group.acessos_masters.id]
  depends_on = [
    aws_instance.k8s_workers,
  ]
}

resource "aws_instance" "k8s_workers" {
  ami           = "ami-0d6806446a46f9b9c"
  instance_type = "t2.medium"
  key_name      = "key-par-devops"
  associate_public_ip_address = true
  subnet_id = "subnet-01aca3d2f7d561284"
  count         = 3
  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_size           = 32
  }
  tags = {
    Name = "k8s_workers-${count.index}"
  }
  vpc_security_group_ids = [aws_security_group.acessos_workers.id]
}


resource "aws_security_group" "acessos_masters" {
  name        = "k8s-acessos_masters"
  description = "acessos inbound traffic"
  vpc_id = "vpc-0a0eeef20f67dfb8d"
  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
    {
      cidr_blocks      = []
      description      = "Libera acesso k8s_masters"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = true
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = "Libera acesso k8s_haproxy"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
        "${aws_security_group.acessos_haproxy.id}",
      ]
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 65535
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids = null,
      security_groups: null,
      self: null,
      description: "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "acessos_haproxy" {
  name        = "k8s-haproxy"
  description = "acessos inbound traffic"
  vpc_id = "vpc-0a0eeef20f67dfb8d"
  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
      #aws_security_group.acessos_masters.id,
        "sg-0994facac220204e6",
      ]
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
      #aws_security_group.acessos_workers.id,
      "sg-0792a50fe9394b614",
      ]
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 65535
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids = null,
      security_groups: null,
      self: null,
      description: "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "allow_haproxy_ssh"
  }
}

resource "aws_security_group" "acessos_workers" {
  name        = "k8s-workers"
  description = "acessos inbound traffic"
  vpc_id = "vpc-0a0eeef20f67dfb8d"
  ingress = [
    {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = null,
      security_groups: null,
      self: null
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = [
        aws_security_group.acessos_masters.id,
      ]
      self             = false
      to_port          = 0
    },
    {
      cidr_blocks      = []
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = true
      to_port          = 65535
    },
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = [],
      prefix_list_ids = null,
      security_groups: null,
      self: null,
      description: "Libera dados da rede interna"
    }
  ]

  tags = {
    Name = "allow_ssh"
  }
}

output "k8s-masters" {
  value = [
    for key, item in aws_instance.k8s_masters :
      "k8s-master ${key+1} - ${item.private_ip} - ssh -i ~/Desktop/devops/treinamentoItau ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

output "output-k8s_workers" {
  value = [
    for key, item in aws_instance.k8s_workers :
      "k8s-workers ${key+1} - ${item.private_ip} - ssh -i ~/Desktop/devops/treinamentoItau ubuntu@${item.public_dns} -o ServerAliveInterval=60"
  ]
}

output "output-k8s_proxy" {
  value = [
    "k8s_proxy - ${aws_instance.k8s_proxy.private_ip} - ssh -i ~/Desktop/devops/treinamentoItau ubuntu@${aws_instance.k8s_proxy.public_dns} -o ServerAliveInterval=60"
  ]
}

output "security-group-workers-e-haproxy" {
  value = aws_security_group.acessos_haproxy.id
}



# terraform refresh para mostrar o ssh
