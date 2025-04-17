resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr               
  enable_dns_hostnames = true
  enable_dns_support   = true
   tags = merge(
    var.tags,
    {
      Name = "my-vpc"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
   tags = merge(
    var.tags,
    {
      Name = "my-vpc-igw"
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  cidr_block              = var.public_subnet_cidrs[count.index]
  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.tags,
    {
      Name                                 = "public-subnet-${count.index}"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/elb"             = "1"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  cidr_block        = var.private_subnet_cidrs[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zones[count.index]
  tags = merge(
    var.tags,
    {
      Name                                      = "private-subnet-${count.index}"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"         = "1"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
   tags = merge(
    var.tags,
    {
      Name = "my-vpc-public-rotetable"
    }
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
   tags = merge(
    var.tags,
    {
      Name = "my-vpc-ngw"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
   tags = merge(
    var.tags,
    {
      Name = "my-vpc-private-routetable"
    }
  )
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "vpc_sg" {
  name        = "vpc-security-group"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
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
## security.tf
resource "aws_security_group" "eks_sg" {
   name        = "eks-sg"
   description = "Allow eks-access"
   vpc_id      = aws_vpc.main.id
  ingress {
     from_port = 443
     to_port = 443 
     protocol = "tcp" 
     cidr_blocks = ["0.0.0.0/0"] 
     }
  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }

   tags = merge(
    var.tags,
    {
      Name = "my-vpc-public-sg"
    }
  )
}
