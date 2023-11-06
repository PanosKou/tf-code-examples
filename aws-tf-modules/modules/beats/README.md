# Beats
Terraform module for deploying beats for eks-epaas.

# Overview
This terraform component is a wrapper for installing and configuring metricbeat and filebeat.

Both are agents to ship metrics & logs respectively.

# Source
Elastic official Helm Charts @ the version specififed in the module.

GitHub: https://github.com/elastic/helm-charts

*Filebeat*: https://github.com/elastic/helm-charts/tree/master/filebeat

*Metricbeat*: https://github.com/elastic/helm-charts/tree/master/metricbeat

# Opinionated
Whilst we are using the official charts and images (and you can feel free to also use them from artifactory) we are not making this terraform component highly configurable. We are very much focused on making this module work in the context of a NBS Cloud epaas scenario.
* We are using the metricbeat k8s deployment (not daemonset) because we are using Prometheus as a metrics aggregator. Given we have process in place to ensure that every component exposes metrics to prometheus and prometheus is a part of every epaas-eks cluster.

# Integration Doc
Includes dependencies for deployment.

https://docs.nationwidebuilding.luminatesec.com/docs/epaas-eks/product-engineering/integrations/elastic/

# Transforms
Filebeat and metric beat add a field `fields.cluster_name` to every event so we can always differentiate which cluster is the source even if things are stored in the same index.

# Networking
So policies can be applied.
https://kubernetes.io/docs/concepts/services-networking/network-policies/
## Ingress
Beats require no inbound traffic.
## Egress
* Inside of cluster metricbeat needs to reach prometheus.
* Outside of cluster to Logstash / Logstash Load Balancer. For eks-epaas this will be in private subnets in the same VPC as the cluster.
## Network Policies
The starting point for the above. This can be narrowed further in time if required. Though, it is common to have open egress policies and it is the responsibility of all components to define effective ingress policies.
* Ingress: Deny all ingress traffic to the beats namespace.
* Egress: Allow all egress traffic from the beats namespace.

# Pod Security Policies
https://kubernetes.io/docs/concepts/policy/pod-security-policy/

To use a PSP you need to "attach" it via the k8s role. The filebeat chart does not currently enable this without a small change and so whilst we have raised the change with elastic we have had to turn the rbac feature off in the chart and create our own service account, cluster role and cluster role binding for filebeat.

*GitHub Issue*: https://github.com/elastic/helm-charts/pull/978

## Security Contexts
https://kubernetes.io/docs/tasks/configure-pod-container/security-context/

For metricbeat we tried to run as a none-root user by messing with the Chart and otherwise to set the Pod Security Context and Container Security context using variations of the examples below. But we weren't able to succeed in the end.
*Pod*:
```
securityContext:
  runAsUser: 10001
  runAsGroup: 100001
  privileged: false
```
*Container*:
```
securityContext:
  runAsUser: 10001
  runAsGroup: 100001
  fsGroup: 10001
```
*Errors*:
```
# Errors returned at different times using different permuations of the above
# 0 
Exiting: error loading config file: open metricbeat.yml: permission denied
# 1
/usr/local/bin/docker-entrypoint: line 8: /usr/share/metricbeat/metricbeat: Permission denied
```

# Artifactory
The Charts and Images have been made internally available to Nationwide without modification using this process: https://docs.nationwidebuilding.luminatesec.com/docs/epaas-eks/product-engineering/integrations/artifactory/

```
# Helm 
helm repo add elastic https://helm.elastic.co
helm  pull elastic/metricbeat
helm  pull elastic/filebeat

# Docker
## Artifactory login
docker login epaas-docker-rel-local.artifactory.aws.nbscloud.co.uk:443 -u epaas-ci

## Metricbeat
docker pull docker.elastic.co/beats/metricbeat:7.10.0
docker tag docker.elastic.co/beats/metricbeat:7.10.0 epaas-docker-rel-local.artifactory.aws.nbscloud.co.uk/beats/metricbeat:7.10.0
docker push epaas-docker-rel-local.artifactory.aws.nbscloud.co.uk/beats/metricbeat:7.10.0

## Filebeat
docker pull docker.elastic.co/beats/filebeat:7.10.0
docker tag docker.elastic.co/beats/filebeat:7.10.0 epaas-docker-rel-local.artifactory.aws.nbscloud.co.uk/beats/filebeat:7.10.0
docker push epaas-docker-rel-local.artifactory.aws.nbscloud.co.uk/beats/filebeat:7.10.0
```

# Debug Config
This will print all output to console instead of sending to logstash.
* 'beats' paths are excluded from filebeat input when using console output to stop a perpetual loop.
* Beats output tests will fail when using console output.

*Filebeat*:
```
filebeatConfig:
  filebeat.yml: |
    filebeat.inputs:
      - type: container
        paths:
          - /var/log/containers/*.log
        exclude_files: ['.*beat.*']
        processors:
        - add_kubernetes_metadata:
            host: $${NODE_NAME}
            matchers:
              - logs_path:
                  logs_path: "/var/log/containers/"
        - add_fields:
            fields:
              cluster_name: ${cluster_name}
    output.console:
        pretty: true
```

*Metricbeat*:
```
deployment:
  metricbeatConfig:
    metricbeat.yml: |
      metricbeat.modules:
        - module: prometheus
          period: 60s
          hosts: ["${prometheus_host_port}"]
          metrics_path: '/federate'
          query:
            'match[]': '{__name__!=""}'
      processors:
        - add_fields:
            fields:
              cluster_name: ${cluster_name}
      output.console:
        pretty: true
```