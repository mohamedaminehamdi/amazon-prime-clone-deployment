#!/bin/bash

# Exit on any error
set -e

# Variables
CLUSTER_NAME="amazonprimeclone"
REGION="eu-north-1"
ZONES="eu-north-1a,eu-north-1b"
K8S_VERSION="1.30"
NODEGROUP_NAME="node2"
NODE_TYPE="t3.medium"
NODE_COUNT=2
NODE_MIN=2
NODE_MAX=4
VOLUME_SIZE=20
SSH_KEY_NAME="amine"  # Replace with your actual SSH key name

# (a) Create the EKS Cluster (without node group)
echo "Creating EKS cluster: $CLUSTER_NAME in region $REGION..."
eksctl create cluster --name=$CLUSTER_NAME \
                      --region=$REGION \
                      --zones=$ZONES \
                      --version=$K8S_VERSION \
                      --without-nodegroup

# (b) Associate IAM OIDC provider
echo "Associating IAM OIDC provider..."
eksctl utils associate-iam-oidc-provider \
    --region $REGION \
    --cluster $CLUSTER_NAME \
    --approve

# (c) Create a managed node group
echo "Creating managed node group: $NODEGROUP_NAME..."
eksctl create nodegroup --cluster=$CLUSTER_NAME \
                        --region=$REGION \
                        --name=$NODEGROUP_NAME \
                        --node-type=$NODE_TYPE \
                        --nodes=$NODE_COUNT \
                        --nodes-min=$NODE_MIN \
                        --nodes-max=$NODE_MAX \
                        --node-volume-size=$VOLUME_SIZE \
                        --ssh-access \
                        --ssh-public-key=$SSH_KEY_NAME \
                        --managed \
                        --asg-access \
                        --external-dns-access \
                        --full-ecr-access \
                        --appmesh-access \
                        --alb-ingress-access

echo "EKS Cluster '$CLUSTER_NAME' and Node Group '$NODEGROUP_NAME' created successfully in $REGION."
