# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "dev-vpc"
    Environment = "development"
    Project     = "nextjs-app"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name        = "dev-public-subnet-${count.index + 1}"
    Environment = "development"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "dev-private-subnet-${count.index + 1}"
    Environment = "development"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "dev-igw"
    Environment = "development"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "dev-public-rt"
    Environment = "development"
  }
}

# Route Table Association for Public Subnets
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "nextjs-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nextjs-alb-sg"
    Environment = "development"
  }
}

# Security Groups
resource "aws_security_group" "nextjs_sg" {
  name        = "nextjs-app-sg"
  description = "Security group for Next.js application"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict this to your IP
  }

  # Next.js application port - only allowing traffic from ALB security group
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "nextjs-app-sg"
    Environment = "development"
  }
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "nextjs-deployer-key"
  public_key = file("~/.ssh/nextjs-deployer.pub")
}

# EC2 Instances
resource "aws_instance" "nextjs_app" {
  count = 2

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  subnet_id                   = aws_subnet.public[count.index].id
  vpc_security_group_ids      = [aws_security_group.nextjs_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name        = "nextjs-app-server-${count.index + 1}"
    Environment = "development"
  }
}

# Application Load Balancer
resource "aws_lb" "nextjs_alb" {
  name               = "nextjs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name        = "nextjs-alb"
    Environment = "development"
  }
}

# Target Group
resource "aws_lb_target_group" "nextjs_tg" {
  name     = "nextjs-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "nextjs_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.nextjs_tg.arn
  target_id        = aws_instance.nextjs_app[count.index].id
  port             = 3000
}

# Listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.nextjs_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nextjs_tg.arn
  }
}
