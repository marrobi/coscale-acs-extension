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
CS_USER=$8
CS_PASS=$9

DIRECTORY=scripts
if ! [ -d "$DIRECTORY" ]; then
    makedir DIRECTORY
fi
cd DIRECTORY
curl https://raw.githubusercontent.com/marrobi/coscale-acs-extension/master/scripts/createCluster.sh -o createCluster.sh
curl https://raw.githubusercontent.com/marrobi/coscale-acs-extension/master/scripts/installCoscale.sh -o installCoscale.sh

echo "--- Running createCluster.sh Date is: `date` ---"
echo "`/bin/bash ./createCluster.sh $SP_NAME $SP_PASS $SP_TENANT $RG_NAME $DC_LOCATION $KUBERNETES_CLUSTER_NAME $KUBERNETES_CLUSTER_DNS`" 
echo "--- Finished createCluster.sh ---"


echo "--- Running installCoscale.sh Date is: `date` ---"
echo "`/bin/bash ./installCoscale.sh $CS_USER $CS_PASS`" 
echo "--- Finished installCoscale.sh ---"