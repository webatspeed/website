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

export KUBECONFIG=./orchestration/config/k3s-webatspeed_node-*.yaml
kubectl apply -f orchestration/frontend.yaml

open https://www.webatspeed.de
```
