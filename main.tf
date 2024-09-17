# Specify the required provider
provider "aws" {
  region = "us-east-1" # Change to your desired region
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # Define the CIDR block for the VPC
  enable_dns_support = true   # Enable DNS support
  enable_dns_hostnames = true  # Enable DNS hostnames
  tags = {
    Name = "main-vpc" # Tag for the VPC
  }
}

# Create public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main.id # Associate with the VPC
  cidr_block        = "10.0.1.0/24"    # Define the CIDR block for the subnet
  availability_zone = "us-east-1a"     # Specify the availability zone
  map_public_ip_on_launch = true        # Enable public IP assignment
  tags = {
    Name = "public-subnet-1" # Tag for the public subnet
  }
}

# Create public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Create private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

# Create private subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id # Associate with the VPC
  tags = {
    Name = "public-route-table" # Tag for the route table
  }
}

# Create route for public route table to the internet
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id # Associate with the public route table
  destination_cidr_block = "0.0.0.0/0"               # Route all traffic to the internet
  gateway_id             = aws_internet_gateway.main.id # Use the internet gateway
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # Attach the internet gateway to the VPC
  tags = {
    Name = "main-internet-gateway" # Tag for the internet gateway
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id # Associate the first public subnet
  route_table_id = aws_route_table.public.id      # With the public route table
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id # Associate the second public subnet
  route_table_id = aws_route_table.public.id      # With the public route table
}

# Create a security group for the ELB
resource "aws_security_group" "elb_sg" {
  vpc_id = aws_vpc.main.id # Associate with the VPC
  tags = {
    Name = "elb-security-group" # Tag for the security group
  }

  # Allow HTTP and HTTPS traffic from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow from anywhere
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow to anywhere
  }
}

# Create an Elastic Load Balancer
resource "aws_elb" "main" {
  name               = "main-elb" # Name of the ELB
  availability_zones = ["us-east-1a", "us-east-1b"] # Availability zones for the ELB
  security_groups    = [aws_security_group.elb_sg.id] # Attach the security group

  listener {
    instance_port     = 80  # Port on the instance
    instance_protocol = "HTTP" # Protocol for the instance
    lb_port           = 80  # Port on the load balancer
    lb_protocol       = "HTTP" # Protocol for the load balancer
  }

  listener {
    instance_port     = 443  # Port on the instance
    instance_protocol = "HTTPS" # Protocol for the instance
    lb_port           = 443  # Port on the load balancer
    lb_protocol       = "HTTPS" # Protocol for the load balancer
    ssl_certificate_id = "your_ssl_certificate_id" # Replace with your SSL certificate ID
  }

  health_check {
    target              = "HTTP:80/" # Health check target
    interval            = 30 # Interval in seconds
    timeout             = 5  # Timeout in seconds
    healthy_threshold  = 2  # Healthy threshold
    unhealthy_threshold = 2  # Unhealthy threshold
  }

  tags = {
    Name = "main-elb" # Tag for the ELB
  }
}

# Create a public Route 53 hosted zone
resource "aws_route53_zone" "public" {
  name = "example.com" # Replace with your domain name
  comment = "Public hosted zone for example.com" # Comment for the hosted zone
}

# Create a CNAME record for the ELB in Route 53
resource "aws_route53_record" "elb_cname" {
  zone_id = aws_route53_zone.public.zone_id # Use the hosted zone ID
  name     = "www.example.com" # CNAME record name
  type     = "CNAME" # Record type
  ttl      = 300 # Time to live
  records   = [aws_elb.main.dns_name] # ELB DNS name
}
