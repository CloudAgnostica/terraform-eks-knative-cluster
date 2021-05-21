# EKS provisioner & Knative setup

Create a Knative EKS EC2 spot instance cluster with request-based cluster autoscaling.

## CI/CD tools

- https://redhat-developer-demos.github.io/knative-tutorial/knative-tutorial/setup/setup.html#tools


## CI/CD creation pipeline

- Create EKS cluster

```
aws ec2 create-key-pair --key-name innovation

terraform init
terraform plan
terraform apply

aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)

./install_knative.sh
./deploy_microservices.sh
./invoke_microservices.sh

```


## Spot implementation

```
./price_introspection.sh
```

## CI/CD deletion pipeline

 - Delete ALB, IGW, SGs,
 - Terraform destroy

```
terraform destroy
```

## Upstream README
### Learn Terraform - Provision an EKS Cluster

This repo is a companion repo to the [Provision an EKS Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-eks-cluster), containing
Terraform configuration files to provision an EKS cluster on AWS.