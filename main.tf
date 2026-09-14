resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/16"
    tags = {
        Name = "main-vpc"
    }   
}    

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_key_pair" "demo" {
  # ssh-keygen -y -f Demo.pem > Demo.pem.pub
  key_name   = "Demo"
  public_key = file("Demo.pem.pub")
}

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-resolute-26.04-amd64-server-*"]
#   }
# }

resource "aws_instance" "demo" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.main.id
  key_name               = aws_key_pair.demo.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "demo-instance"
  }
}

output "public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.demo.public_ip
}
