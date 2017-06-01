#!/bin/bash

# Service princaple details
SP_NAME=$1
SP_PASS=$2
SP_TENANT=$3

# Azure configuration
RG_NAME=$4
DC_LOCATION=$5

# Kube cluster configuration
KUBERNETES_CLUSTER_NAME=$6
KUBERNETES_CLUSTER_DNS=$7

# CoScale config
COSCALE_USERNAME=$8
COSCALE_PASSWORD=$9

# $1 SP_NAME name of service principal
# $2 SP_PASS password of service principal
# $3 SP_TENANT the tenant
function azureLogin() {
    az login --service-principal -u $1 -p $2 --tenant $3
}

# $1 resource group name
# $2 location for it
function azureCreateResourceGroup() {
    az group create --name $1 --location $2
}

# $1 Resource group where it should be added
# $2 Location of the cluster
# $3 Name of the kubernetes cluster
# $4 DNS Prefix for the cluster
# $5 Name of the service principal
# $6 Password for the service principal
function azureCreateACSCluster() {
    az acs create \
        --resource-group=$1 \
        --location=$2 \
        --orchestrator-type=kubernetes \
        --master-count=3 \
        --agent-count=5 \
        --agent-vm-size=Standard_DS4_v2 \
        --admin-username=coscaleadmin \
        --name=$3 \
        --dns-prefix=$4 \
        --service-principal $5 \
        --client-secret $6 \
        --generate-ssh-keys
}

# $1 Resource group of the cluster
# $2 Kubernetes cluster Name
function azureConfigureKubectl() {
    az acs kubernetes get-credentials --resource-group=$RG  --name=$CL_NAME
}

# Login to azure and check if successful
AZURE_LOGIN=$(azureLogin $SP_NAME $SP_PASS $SP_TENANT)
if [[ "$AZURE_LOGIN" = "" ]]; then
    echo -e "\x1B[31m  --- Unable to log into azure ---  \x1B[0m"
    exit 1;
else
    echo "Azure login succesful"
    echo $AZURE_LOGIN
fi

# Create the azure resource group
CREATE_RESOURCE_GROUP=$(azureCreateResourceGroup $RG_NAME $DC_LOCATION)
if [[ "$CREATE_RESOURCE_GROUP" = "" ]]; then
    echo -e "\x1B[31m  --- Unable to create the resource group ---  \x1B[0m"
    exit 1;
else
    echo "Azure resource group created"
    echo $CREATE_RESOURCE_GROUP
fi

# Create the acs cluster
CREATE_ACS_CLUSTER=$(azureCreateACSCluster $RG_NAME $DC_LOCATION $KUBERNETES_CLUSTER_NAME $KUBERNETES_CLUSTER_DNS $SP_NAME $SP_PASS)
if [[ "$CREATE_ACS_CLUSTER" = "" ]]; then
    echo -e "\x1B[31m  --- Unable to create acs cluster ---  \x1B[0m"
    exit 1;
else
    echo "ACS cluster created"
    echo $CREATE_ACS_CLUSTER
fi

# Configure kubectl to use the new credentials
SETUP_KUBECTL=$(azureConfigureKubectl $RG_NAME $KUBERNETES_CLUSTER_NAME)
if [[ "$SETUP_KUBECTL" = "" ]]; then
    echo -e "\x1B[31m  --- Unable to configure kubectl ---  \x1B[0m"
    exit 1;
else
    echo "ACS cluster created"
    echo $SETUP_KUBECTL
fi
