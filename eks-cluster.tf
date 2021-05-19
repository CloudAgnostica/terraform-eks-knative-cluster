module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  cluster_version = "1.17"
  subnets = module.vpc.private_subnets

  tags = {
    Environment = "training"
    GithubRepo = "terraform-aws-eks"
    GithubOrg = "terraform-aws-modules"
  }

  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
    key_name = "innovation"
  }

  worker_groups = [
    {
      name = "worker-group-1"
      instance_type = "t3a.medium"
      additional_userdata = "echo foo bar"
      asg_desired_capacity = 3
      additional_security_group_ids = [
        aws_security_group.worker_group_mgmt_one.id, aws_security_group.worker_group_http_one.id]
    },
    {
      name = "worker-group-2"
      instance_type = "t3a.large"
      additional_userdata = "echo foo bar"
      additional_security_group_ids = [
        aws_security_group.worker_group_mgmt_two.id, aws_security_group.worker_group_http_two.id]
      asg_desired_capacity = 3

    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
