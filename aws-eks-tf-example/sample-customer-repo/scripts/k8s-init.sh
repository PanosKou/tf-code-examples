#!/usr/bin/env bash
#This script takes cluster name as argument and generates kubeconfig on the fly.
CLUSTER_NAME=$1

echo "*****> initialisation script for eks cluster"
echo "CLUSTER_NAME=${CLUSTER_NAME}"
aws eks --region=eu-west-2 update-kubeconfig --name ${CLUSTER_NAME} --alias "${CLUSTER_NAME}"