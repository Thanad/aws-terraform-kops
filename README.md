# AWS Terraform and kops

## Requirements

 - AWS CLI
 - kops ~1.13.0
 - Terraform ~0.12.0

## Setup aws credential and config region "ap-southeast-1"
```
aws --profile=example configure
```

## Setup env variable 
```
export AWS_PROFILE=example
export CLUSTER_NAME=cluster.k8s.local
export BUCKET_NAME=${AWS_PROFILE}-state-store
export KOPS_STATE_STORE=s3://${BUCKET_NAME}
```

## Create s3 buckets
```
aws s3api create-bucket --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=ap-southeast-1 --region ap-southeast-1
```

## Init terraform
```
terraform init -backend-config="profile=${AWS_PROFILE}" -backend-config="bucket=${BUCKET_NAME}" terraform/
```

## Create vpc with terraform
```
terraform plan terraform/
terraform apply terraform/
```

## List ec2 availability zone 
```
aws ec2 describe-availability-zones --region ap-southeast-1
```

## Create ssh key
```
ssh-keygen -f keys/kubernetes
```

## Create cluster with kops 
```
# Create yaml for with kops for create cluster 
kops create cluster \
--vpc=vpc-070deb8d4297e6b54 \
--zones ap-southeast-1a,ap-southeast-1b,ap-southeast-1c \
--networking weave \
--topology private \
--master-zones=ap-southeast-1a,ap-southeast-1b,ap-southeast-1c \
--master-size=t3.medium \
--node-size=t3.medium \
--node-count=1 \
--ssh-public-key=keys/kubernetes.pub \
--dry-run --output=yaml \
--name $CLUSTER_NAME > kops/cluster-ig.yaml

# create cluster and instancegroup from yaml
kops create -f kops/cluster-ig.yaml

# Create ssh key secret 
kops create secret --name $CLUSTER_NAME sshpublickey admin -i keys/kubernetes.pub

# Apply update to aws
kops update cluster $CLUSTER_NAME --yes

# Then I can use 
kops validate cluster $CLUSTER_NAME
```

## Add bastion hosts after added cluster
https://github.com/kubernetes/kops/issues/2881
```
kops create instancegroup --role=Bastion --name $CLUSTER_NAME bastion --dry-run --output=yaml > kops/bastion.yaml
kops create --name=$CLUSTER_NAME -f kops/cluster-ig.yaml
kops update cluster $CLUSTER_NAME --yes
```

## To update cluster or instance groups
```
kops replace --name=$CLUSTER_NAME -f kops/cluster-ig.yaml
kops update cluster $CLUSTER_NAME
kops update cluster $CLUSTER_NAME --yes
kops rolling-update cluster --name=$CLUSTER_NAME
kops rolling-update cluster --name=$CLUSTER_NAME --yes
```

## Delete cluster
```
kops delete cluster $CLUSTER_NAME
kops delete cluster $CLUSTER_NAME --yes

terraform plan -destroy terraform/
terraform destroy terraform/
```

