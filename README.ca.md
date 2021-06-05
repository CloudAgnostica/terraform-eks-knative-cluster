# EKS Cluster autoscaling implementation

- Set the cluster name:

```
export CLUSTER_NAME=$(terraform output -raw cluster_name)
```
  
- Set the eksctl [IAM OIDS provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html):

```
eksctl utils associate-iam-oidc-provider --region=$(terraform output -raw region) --cluster=${CLUSTER_NAME} --approve

```

- Create policy and service account for [cluster autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html#ca-create-policy)

```
aws iam create-policy \
    --policy-name AmazonEKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler-policy.json
    
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

eksctl create iamserviceaccount \
  --cluster=${CLUSTER_NAME} \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AmazonEKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve  

```
- Get the name of the role from eksctl created CloudFormation & set a variable.

Example:
```
export CA_ROLE_NAME=eksctl-innovation-eks-GfURKxDq-addon-iamserv-Role1-1CVZH5BJNHYC1
```

- Deploy the [cluster autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html#ca-deploy) deployment:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml

```


- This may cause an error: --overwrite is false but found the following declared annotation(s): 'eks.amazonaws.com/role-arn' already has a value (arn:aws:iam::XXXXXX:role/eksctl-innovation-eks-GfURKxDq-addon-iamserv-Role1-1CVZH5BJNHYC1)
```
kubectl annotate serviceaccount cluster-autoscaler \
  -n kube-system \
  eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CA_ROLE_NAME}
  
```
- patch deployment with safe-to-evict
```
  kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'
  
  
  kubectl -n kube-system edit deployment.apps/cluster-autoscaler
  
```

- Assuming 1.17 Kubernetes version below

```
kubectl set image deployment cluster-autoscaler \
  -n kube-system \
  cluster-autoscaler=k8s.gcr.io/autoscaling/cluster-autoscaler:v1.17.4
```

## Cluster autoscaler detailed dive resources

- [K8s CA FAQ](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/FAQ.md)
- [AWS Cluster Autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)