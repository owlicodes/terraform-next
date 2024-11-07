# Terraform Config for Next.js Todo Application

This project is used to provision aws resources for the **todo-application** Next.js application. The idea of this config is to setup a development environment.

## Initialize Terraform

```bash
terraform init
```

## Verify the Resources

```bash
terraform plan
```

## Create the Resources

```bash
terraform apply
```

## Delete the Resources

```bash
terraform destroy
```

## Generate SSH Key Pair for EC2 Instance

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/nextjs-deployer
```

## Manually Deploying a Next.js Application

To manually deploy a Next.js Application to the EC2 instances, follow the steps in the todo-application project readme guide.