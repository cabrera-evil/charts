<!--

********************************************************************************

WARNING:

    DO NOT EDIT "deploy-chart/README.md"

    IT IS PARTIALLY AUTO-GENERATED

    (based on Helm templates, values, and CLI tooling)

********************************************************************************

-->

# Quick reference

- **Maintained by**:  
  [Douglas Cabrera](https://cabrera-dev.com)

- **Where to get help**:  
  [GitHub Issues](https://github.com/cabrera-evil/charts/issues)

# What is this chart?

**deploy-chart** is a generic and flexible Helm chart for deploying containerized applications into Kubernetes clusters. It includes modular templates for key Kubernetes objects such as Deployments, Services, Ingress, ConfigMaps, Secrets, Autoscaling, and more. The chart is designed to serve as a reusable base for production-ready workloads.

# How to use this chart

## Add the Helm repository

```bash
helm repo add cabrera-evil https://cabrera-evil.github.io/charts/
helm repo update
```

## Install the chart

```bash
helm install <release-name> cabrera-evil/deploy-chart
```

## Upgrade the chart

```bash
helm upgrade <release-name> cabrera-evil/deploy-chart
```

## Uninstall the chart

```bash
helm uninstall <release-name>
```

> Use `--values custom.yaml` or `--set key=value` to override default configuration.

# Chart features

- Deployments with configurable replica count
- Service (ClusterIP/NodePort/LoadBalancer) exposure
- Ingress support with custom hosts and paths
- ConfigMaps and Secrets for environment-specific configuration
- Horizontal Pod Autoscaler (HPA)
- Resource requests and limits (CPU, memory)
- Liveness and readiness probes
- Custom annotations and labels
- RBAC / ServiceAccount support

# Configuration

Values are defined in `values.yaml` and can be overridden using `--set` or a custom values file.

## Example values

```yaml
replicaCount: 1

image:
  repository: nginx
  tag: "latest"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  hosts:
    - host: example.local
      paths:
        - path: /
          pathType: Prefix
```

## Secrets and ConfigMaps

Sensitive data and app configuration can be managed using:

```yaml
configMap:
  enabled: true
  data:
    APP_ENV: production

secret:
  enabled: true
  data:
    DATABASE_PASSWORD: s3cr3t
```

# License

This chart is released under the [MIT License](./LICENSE).
