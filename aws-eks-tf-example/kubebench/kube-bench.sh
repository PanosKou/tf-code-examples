#!/usr/bin/env bash

kube_bench_container_name='job-name=kube-bench'
rundate=$(date +"%d_%m_%Y_%I_%M_%p")
export KUBECONFIG=/opt/app/config

kubectl apply -f /opt/app/kubebench/job-eks.yaml

sleep 20

echo "starting executing CIS kube-bench ${rundate}"
kube_bench_pod=$(kubectl get --no-headers=true pods -l ${kube_bench_container_name} -o custom-columns=:metadata.name) 
echo "${kube_bench_pod}"
kubectl logs ${kube_bench_pod}
echo "CIS kube-bench ended at  ${rundate}"

echo " cleaning up kube-bench"

kubectl delete -f /opt/app/kubebench/job-eks.yaml
