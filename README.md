# terraform
This repository is used for terraform
# 1) Azure Architecture with Terraform

![Azure Architecture](/Azure%20Architecture/Azure%20Architecture1.jpg)

## Overview

This repository contains Terraform configuration to deploy an Azure architecture. The architecture consists of interconnected cloud services to meet project requirements.

## Created Resources

### 1. Resource Group
   A fundamental grouping of resources providing isolation, management, and policy enforcement.

### 2. CosmosDB Account
   A globally distributed, multi-model database service for various data types.

### 3. Event Hub
   A scalable event processing service that ingests and processes data from various sources.

### 4. Function App
   A serverless compute service that runs code in response to events and automatically manages resources.

### 5. Service Bus
   A fully managed enterprise message broker with high availability and reliability.

### 6. Azure Container Registry
   A managed Docker registry service for storing and managing container images.

### 7. Azure Container Group (ACI)
   A containerized application service for deploying and managing containers using Azure Container Instances.

## Implementation Instructions

1. Clone this repository.
2. Adjust variables in the `terraform.tfvars` file as needed.
3. Run `terraform init` followed by `terraform apply` to deploy the architecture in Azure.

## Important Notes

- Review and customize configurations based on specific requirements.
- Keep sensitive information such as keys and passwords secure.

Thank you for using this project! If you have any questions, feel free to contact me.
