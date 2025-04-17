variable "aws_region" { default = "us-east-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }


variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnet_cidrs" { 
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"] 
}


variable "availability_zones" {
  type = list(string)
  default=["us-east-1a","us-east-1b","us-east-1c","us-east-1d"]
}

# Global tags
variable "tags" {
  type = map(string)
  default = {
    Project = "my-project"
  }
}

variable "cluster_name" {
  type = string
  default = "my-eks-cluster"
}
