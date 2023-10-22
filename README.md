# Web at Speed website

- Terraform (Cloud)
- AWS (VPC, ELB, EC2, ACM, RDS, Route 53, SES)
- Kubernetes (K3s)
- Docker
    - [webatspeed/webatspeed-fe](https://hub.docker.com/r/webatspeed/webatspeed-fe/tags)
- bash

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
 --from-literal username=<username> \
 --from-literal password=<password>
kubectl create secret generic ses-credentials \
 --from-literal username=<username> \
 --from-literal password=<password> \
 --from-literal email=<email>

kubectl apply -f ..

open https://www.webatspeed.de
```
