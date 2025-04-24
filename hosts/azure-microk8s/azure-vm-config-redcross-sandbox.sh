#!/bin/bash
# filename: azure-vm-config-redcross-sandbox.sh
# description: Configuration file for Azure VM scripts for Red Cross Sandbox

# Azure configuration variables
TENANT_ID="d34df49e-8ff4-46d6-b78d-3cef3261bcd6"
SUBSCRIPTION_ID="68bf1e87-1a04-4500-ab03-cc04054b0862"
RESOURCE_GROUP="rg-sandbox-k8s-weu"
IMAGE="Ubuntu2204"
VM_SIZE="Standard_B2ms"
LOCATION="westeurope"
AUTH_TYPE="password"
STORAGE_SKU="Standard_LRS"
OS_DISK_SIZE="30"
TAGS="CostCenter=IKT Project=kubernetes-test Environment=Sandbox Description='Kubernetes (MicroK8s) cluster node for test and development' BusinessOwner=terje.christensen@redcross.no ITOwner=terje.christensen@redcross.no"
AZURE_CLUSTER_INFO="azure-microk8s.sh"

# Data disk configuration
DATA_DISK_SIZE="50"
DATA_DISK_SKU="Standard_LRS"
MOUNT_POINT="/mnt/urbalurbadisk"

# Network-related variables
# Centralized network resource group for shared networking components
NETWORK_RG="rg-sandbox-network-weu"
VNET_NAME="vnet-sandbox-network-weu"
SUBNET_NAME="sub-sandbox-k8s-weu"
NETWORK_BASE_PATH="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$NETWORK_RG/providers/Microsoft.Network"
VNET_FULL_PATH="$NETWORK_BASE_PATH/virtualNetworks/$VNET_NAME"
SUBNET_FULL_PATH="$VNET_FULL_PATH/subnets/$SUBNET_NAME"

# Network address spaces
VNET_ADDRESS_SPACE="10.2.0.0/16"
SUBNET_ADDRESS_PREFIX="10.2.1.0/24"

# Function to generate resource names based on VM_INSTANCE
generate_resource_names() {
    VM_INSTANCE_NAME="vm-sandbox-k8s-${VM_INSTANCE}-weu"
    NIC_NAME="nic-sandbox-k8s-${VM_INSTANCE}-weu"
    NSG_NAME="nsg-sandbox-k8s-${VM_INSTANCE}-weu"
    OS_DISK_NAME="disk-os-sandbox-k8s-${VM_INSTANCE}-weu"
    DATA_DISK_NAME="disk-data-sandbox-k8s-${VM_INSTANCE}-weu"
}