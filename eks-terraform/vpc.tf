
#Create a custom VPC
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "MyProjectVPC"
  }
}

#Create Subnets
resource "aws_subnet" "subnet01" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "MyPublicSubnet01"
  }
}

resource "aws_subnet" "subnet02" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "MyPublicSubnet02"
  }
}

# Creating Internet Gateway IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    "Name" = "MyIGW"
  }
}

# Creating Route Table
resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    "Name" = "MyPublicRouteTable"
  }
}

# Create a Route in the Route Table with a route to IGW
resource "aws_route" "myigw_route" {
  route_table_id         = aws_route_table.routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Subnets with the Route Table
resource "aws_route_table_association" "Mysubnet01_association" {
  route_table_id = aws_route_table.routetable.id
  subnet_id      = aws_subnet.subnet01.id
}

resource "aws_route_table_association" "Mysubnet02_association" {
  route_table_id = aws_route_table.routetable.id
  subnet_id      = aws_subnet.subnet02.id
}


#Adding security group
resource "aws_security_group" "allow_tls" {
  name_prefix   = "allow_tls_"
  description   = "Allow TLS inbound traffic"
  vpc_id        = aws_vpc.myvpc.id

  ingress {
    description = "TLS from VPC"
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
}