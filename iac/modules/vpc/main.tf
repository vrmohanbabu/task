provider "aws" {
  region = "us-east-1"
}

data "aws_region" "available" {}

resource "aws_vpc" "DemoVPC" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "${var.project_name}-${var.environment_name}-vpc"
  }
}

data "aws_availability_zones" "available_zones" {}

resource "aws_subnet" "PublicSubnetA" {
  vpc_id                  = aws_vpc.DemoVPC.id
  cidr_block              = var.public_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment_name}-PublicSubnetA"
  }
}

resource "aws_subnet" "PublicSubnetB" {
  vpc_id                  = aws_vpc.DemoVPC.id
  cidr_block              = var.public_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment_name}-PublicSubnetB"
  }
}

resource "aws_subnet" "PrivateSubnetA" {
  vpc_id            = aws_vpc.DemoVPC.id
  cidr_block              = var.private_subnet_az1_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]

  tags = {
    Name = "${var.project_name}-${var.environment_name}-PrivateSubnetA"
  }
}

resource "aws_subnet" "PrivateSubnetB" {
  vpc_id            = aws_vpc.DemoVPC.id
  cidr_block              = var.private_subnet_az2_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[1]

  tags = {
    Name = "${var.project_name}-${var.environment_name}-PrivateSubnetB"
  }
}

resource "aws_internet_gateway" "DemoIGW" {
  vpc_id = aws_vpc.DemoVPC.id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-igw"
  }
}


resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.DemoVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DemoIGW.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment_name}-PublicRouteTable"
  }

}


resource "aws_route_table" "PrivateRouteTable" {
  vpc_id = aws_vpc.DemoVPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pub_natgw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment_name}-PrivateRouteTable"
  }

}

resource "aws_route_table_association" "PubRtA" {
  subnet_id      = aws_subnet.PublicSubnetA.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "PubRtB" {
  subnet_id      = aws_subnet.PublicSubnetB.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_route_table_association" "PriRtA" {
  subnet_id      = aws_subnet.PrivateSubnetA.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}

resource "aws_route_table_association" "PriRtB" {
  subnet_id      = aws_subnet.PrivateSubnetB.id
  route_table_id = aws_route_table.PrivateRouteTable.id
}


resource "aws_eip" "nat_eip" {

  domain = "vpc"

  lifecycle {
    # prevent_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment_name}-nat_eip"
  }

}

resource "aws_nat_gateway" "pub_natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.PublicSubnetA.id

  tags = {
    Name = "${var.project_name}-${var.environment_name}-pub_natgw"
  }

  depends_on = [aws_internet_gateway.DemoIGW]
}

