# Web at Speed Website

- Terraform (Cloud)
- AWS (VPC, ELB, EC2, ACM, RDS, Route 53, SES, S3)
- Kubernetes (K3s)
- Docker
    - [webatspeed/webatspeed-fe](https://hub.docker.com/r/webatspeed/webatspeed-fe/tags)
- bash

## Infrastructure and Orchestration

![Infrastructure and Orchestration](infra.svg "Infrastructure and Orchestration")

## Installation

```
git clone https://github.com/webatspeed/website.git
cd website

cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
terraform init && terraform apply -auto-approve

cd orchestration/config
export KUBECONFIG=$(ls -1t *.yaml | head -1)
kubectl create secret generic mongo-credentials \
 --from-literal username='<username>' \
 --from-literal password='<password>'
kubectl create secret generic ses-credentials \
 --from-literal username='<username>' \
 --from-literal password='<password>' \
 --from-literal email='<email>' \
 --from-literal region='<region>' \
 --from-literal bucket='<bucket>'

kubectl apply -f ..

open https://www.webatspeed.de
```

## Distribute Newsletter

```
./orchestration/scripts/distribute.sh
```

## Backup Subscribers

```
./orchestration/scripts/mongodump.sh /directory/to/save
```
