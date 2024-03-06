# Web at Speed Website

- Terraform (Cloud)
- AWS Serverless (VPC, ELB, ECS, Fargate, ACM, EFS, Route 53, Cloud Map, SES, S3)
- AWS Developer Tools (CodePipeline, CodeBuild, GitHub Codestar Connection, IAM, S3)
- Docker
    - [webatspeed/webatspeed-fe](https://hub.docker.com/r/webatspeed/webatspeed-fe/tags) (ReactJS)
    - [webatspeed/subscription-service](https://hub.docker.com/r/webatspeed/subscription-service/tags) (Spring Boot)
    - [docker/library/mongo](https://gallery.ecr.aws/docker/library/mongo) (MongoDB)
- bash

## Infrastructure, Orchestration, and Continuous Deployment

![Infrastructure, Orchestration, and Continuous Deployment](infra.svg "Infrastructure, Orchestration, and Continuous Deployment")

## Installation

```
git clone https://github.com/webatspeed/website.git
cd website

cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
terraform init && terraform apply -auto-approve

open https://www.webatspeed.de
```

## Distribute Newsletter

```
./container/scripts/distribute.sh
```

## Get Number of Subscribers

```
./container/scripts/countsubscribers.sh
```

## Find by Email

```
./container/scripts/findemail.sh name@domain.com
```

## Delete by Email

```
./container/scripts/deletesubscriber.sh name@domain.com
```
