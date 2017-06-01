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

curl https://raw.githubusercontent.com/marrobi/coscale-acs-extension/master/scripts/createCluster.sh -o createCluster.sh
curl https://raw.githubusercontent.com/marrobi/coscale-acs-extension/master/scripts/installCoscale.sh -o installCoscale.sh

