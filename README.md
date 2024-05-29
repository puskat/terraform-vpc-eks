# Terraform EKS Cluster Deployment

## Overview

This project sets up a secure and scalable Amazon EKS cluster using Terraform. The setup includes the creation of a VPC, subnets, route tables, and an EKS cluster with node groups. Additionally, it configures IAM roles and policies for secure and efficient management of the cluster.

## VPC Configuration

1. **VPC with DNS Support**:
   - A VPC with DNS support enabled is created. DNS support is necessary for ACM certificates and service discovery within the cluster.

2. **Subnets and Route Table**:
   - Two private subnets are created within the VPC.
   - One route table is created and associated with these subnets.
   - To ensure the cluster remains private, no NAT gateway or Internet Gateway (IGW) is created.
   - VPC endpoints for S3, ECR, and ACM are associated with the route table, enabling the cluster to communicate with these services without requiring internet access.

## EKS Configuration

1. **EKS Cluster**:
   - An EKS cluster is defined within the private subnets.

2. **Node Group and Launch Template**:
   - A node group is created for the cluster using a launch template.
   - The launch template specifies instance types, AMI, and EBS volume configurations for the nodes.

3. **IAM Roles and Policies for Nodes**:
   - The following AWS EKS policies are attached to the nodes for basic EKS permissions:
     - `AmazonEKSWorkerNodePolicy`
     - `AmazonEKS_CNI_Policy`
     - `AmazonEC2ContainerRegistryReadOnly`
     - `AmazonSSMManagedInstanceCore`

4. **IAM Roles for Service Accounts**:
   - An OIDC provider and corresponding IAM roles are created to allow service accounts in the cluster to assume roles using their OIDC identities. This prevents unnecessary permission assignments to the EKS nodes.

5. **IAM Role for Autoscaling**:
   - An IAM role for the cluster autoscaler is created. This role can be assumed by the autoscaler when it is deployed to the cluster, allowing it to manage the scaling of the node groups efficiently.

## Cluster Autoscaler

An IAM role is created for the cluster autoscaler to manage scaling operations. The autoscaler will use this role to interact with the Amazon EC2 Auto Scaling service.

## Conclusion

This setup ensures that the EKS cluster is secure, scalable, and follows best practices for IAM roles and permissions management. By using Terraform, the infrastructure is defined as code, making it easy to manage and version control.

## Getting Started

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- AWS CLI configured with appropriate permissions.

### Usage

1. Initialize Terraform:
    ```bash
    terraform init
    ```

2. Validate the configuration:
    ```bash
    terraform validate
    ```

3. Plan the deployment:
    ```bash
    terraform plan -out=tfplan
    ```

4. Apply the deployment:
    ```bash
    terraform apply tfplan
    ```

### Outputs

After applying the configuration, Terraform will output relevant information such as the VPC ID, subnet IDs, route table ID, EKS cluster name, endpoint, and other useful details.

---

This README provides an overview of the Terraform configuration for setting up an EKS cluster. For detailed configuration and customization, please refer to the respective Terraform files.
