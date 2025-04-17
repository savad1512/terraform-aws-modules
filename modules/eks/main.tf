resource "aws_eks_cluster" "eks_cluster" {
  name     = var.eks_cluster_name
  role_arn = var.role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = merge(
    var.tags,
    {
      Name = "my-eks-cluster"
    }
  )
}

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.eks_cluster_name}-ng"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = var.node_instance_type

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = merge(
    var.tags,
    {
      Name = "my-eks-nodegroup"
    }
  )
}
