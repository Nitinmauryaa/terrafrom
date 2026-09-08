    provider "aws"{
        region = "ap-south-1"

    }
    resource "aws_security_group" "allow_ssh" {
        name = "allow_ssh"
        description = "Allow SSH access"
        ingress {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
    resource "aws_instance" "my_first_server"{
        ami = "ami-007020fd9c84e18c7"
        instance_type = "t2.nano"
        key_name = "test"
        vpc_security_group_ids = [aws_security_group.allow_ssh.id]
        tags = {
            Name = "my first server"
        }
    }
    output "instance_public_ip" {
        value = aws_instance.my_first_server.public_ip
    }