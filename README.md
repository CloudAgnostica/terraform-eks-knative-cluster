# EKS, Knative, & Cluster autoscaling

Create a Knative EKS with request-based cluster autoscaling.

## CI/CD tooling

- https://redhat-developer-demos.github.io/knative-tutorial/knative-tutorial/setup/setup.html#tools


## Resource creation CI/CD stages

Key stages:

- keypair creation (not idempotent), 
- Terraform EKS cluster creation, 
- Knative install with HPA,
- Deploy microservices,
- Deploy cluster autoscaling

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

See Knative HPA in action:
[![See Knative HPA in action](http://img.youtube.com/vi/qIJunS2pDTA/0.jpg)](https://youtu.be/qIJunS2pDTA?t=170)

### EKS Cluster Autoscaling

1. Verify EKS cluster created by Terraform has [cluster autoscaler tagging](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html#ca-prerequisites)
2. Watch the nodes:
```
watch kubectl get nodes

```
3. Create IAM and deploy cluster autoscaling using [steps here](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html#ca-create-policy)
4. Watch the node count drop.



## Resource cleanup CI/CD stages

High-level stages:

 - Delete ALB, IGW, SGs by deleting Knative sample microservices K8s resources
 - terraform destroy

## Fun to follow...

### Spot implementation

```
./price_introspection.sh
```