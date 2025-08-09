# main.tf

# 1. Configura o provedor (AWS) e a região.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Procura dinamicamente pela AMI mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# 2. Cria uma VPC para nossa rede.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # Faixa de IPs para rede

  tags = {
    Name = "vpc-principal"
  }
}

# 3. Cria uma Sub-rede pública.
# "map_public_ip_on_launch = true" garante que a instância receba um IP público.
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-publica"
  }
}

# 4. Cria um Gateway de Internet para conectar a VPC à internet.
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gateway-principal"
  }
}

# 5. Cria uma Tabela de Rotas para direcionar todo o tráfego externo (0.0.0.0/0) para o Gateway de Internet.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "tabela-rotas-publica"
  }
}

# Associa a Tabela de Rotas à Sub-rede.
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}

# 6. Cria um Grupo de Segurança (firewall).
# Libera acesso na porta 22 (SSH) para gerenciamento e 80 (HTTP) para o site.
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Permite trafego HTTP e SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Libera para qualquer IP
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite acesso de qualquer origem, em prod restrir IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-allow-web"
  }
}

# 7. Cria a Instância EC2
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro" # Tipo do Free Tier
  
  subnet_id = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  # Script que será executado na primeira vez que a máquina iniciar.
  # Ele atualiza o sistema, instala e inicia o Nginx.
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "Servidor Web Nginx"
  }
}