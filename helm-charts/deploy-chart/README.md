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

- **Chart Version**: 0.3.0+
- **Kubernetes Version**: >=1.19.0-0

# What is this chart?

**deploy-chart** is a production-ready, enterprise-grade Helm chart for deploying containerized applications into Kubernetes clusters. Built with best practices from professional charts (Bitnami, GitLab, Kubernetes community), it provides comprehensive support for deployments, services, ingress, jobs, CronJobs, autoscaling, and advanced Kubernetes features.

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

## Core Features

- **Deployments** with configurable replicas, strategies, and pod spec options
- **Services** with multi-port support, session affinity, and IPv6
- **Ingress** with version-aware APIs, per-path backends, and default backends
- **ConfigMaps** and **Secrets** with immutable support and multiple data formats
- **Horizontal Pod Autoscaler (HPA)** with custom metrics and scaling behavior
- **Jobs** and **CronJobs** with Helm hooks for lifecycle management
- **ServiceAccount** with RBAC support
- **PodDisruptionBudget** for high availability
- **NetworkPolicy** for network isolation

## Advanced Features

### Deployment Features

- Revision history and rollback configuration
- Multiple container ports support
- Pod topology spread constraints
- Init containers and sidecars
- Lifecycle hooks (preStop, postStart)
- Advanced scheduling (priority class, node selectors, affinity, tolerations)
- Custom DNS configuration
- Host aliases support
- Security contexts and pod security

### Service Features

- Multiple ports with app protocol support
- External IPs and load balancer configuration
- Session affinity with client IP tracking
- Traffic policies (Local/Cluster)
- Dual-stack IPv4/IPv6 support
- Health check node ports

### Jobs & CronJobs Features

- Helm hooks (pre-install, post-install, pre-upgrade, etc.)
- Scheduled CronJobs with timezone support
- Indexed jobs for parallel batch processing
- Pod failure policies
- Success policies (k8s 1.30+)
- Completion modes and backoff limits
- TTL for automatic cleanup

### Autoscaling Features

- CPU and memory-based scaling
- Custom metrics support
- Scaling behavior policies (k8s 1.23+)
- Stabilization windows

# Configuration

Values are defined in `values.yaml` and can be overridden using `--set` or a custom values file.

## Basic Example

```yaml
replicaCount: 3

image:
  repository: myapp/backend
  tag: "1.2.3"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  className: traefik
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

## Secrets and ConfigMaps

### Secrets (Recommended: Use `stringData`)

```yaml
secret:
  enabled: true
  # Use stringData for raw values (Kubernetes auto-encodes)
  stringData:
    DATABASE_PASSWORD: "my-secret-password"
    API_KEY: "abc123xyz"
    USERNAME: "admin"

# Alternative: Use data for pre-encoded base64 values
#   data:
#     DATABASE_PASSWORD: "bXktc2VjcmV0LXBhc3N3b3Jk"
```

### ConfigMaps

```yaml
configMap:
  enabled: true
  # Simple key-value pairs
  data:
    APP_ENV: "production"
    LOG_LEVEL: "info"
    # Complex YAML data
    config.yaml: |
      server:
        port: 8080
        host: 0.0.0.0
      database:
        pool_size: 10
```

## Multiple Service Ports

```yaml
service:
  type: ClusterIP
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: metrics
      port: 9090
      targetPort: metrics
      protocol: TCP
      appProtocol: http

containerPorts:
  - name: http
    containerPort: 8080
    protocol: TCP
  - name: metrics
    containerPort: 9090
    protocol: TCP
```

## High Availability Setup

```yaml
replicaCount: 3

# Pod Disruption Budget
podDisruptionBudget:
  enabled: true
  minAvailable: 2

# Topology spread for zone distribution
topologySpreadConstraints:
  - maxSkew: 1
    topologyKey: topology.kubernetes.io/zone
    whenUnsatisfiable: DoNotSchedule

# Anti-affinity to spread across nodes
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          topologyKey: kubernetes.io/hostname
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: myapp
```

## Autoscaling with Custom Metrics

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  # Standard CPU/Memory metrics
  targetCPUUtilizationPercentage: 70
  targetMemoryUtilizationPercentage: 80
  # Or use custom metrics
  metrics:
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: "1000"
  # Scaling behavior
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 50
          periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
```

## Jobs and CronJobs

### Database Migration Job (Helm Hook)

```yaml
jobs:
  - name: db-migrate
    enabled: true
    # Run before install/upgrade
    hooks:
      - pre-install
      - pre-upgrade
    hookWeight: "-5"
    hookDeletePolicy:
      - before-hook-creation
    # Job configuration
    command: ["rails", "db:migrate"]
    completions: 1
    backoffLimit: 3
    ttlSecondsAfterFinished: 300
    resources:
      requests:
        cpu: 100m
        memory: 256Mi
```

### Scheduled Cleanup CronJob

```yaml
jobs:
  - name: cleanup
    enabled: true
    # Run daily at 2 AM UTC
    schedule: "0 2 * * *"
    timeZone: "UTC"
    concurrencyPolicy: Forbid
    successfulJobsHistoryLimit: 3
    failedJobsHistoryLimit: 1
    command: ["python", "cleanup.py"]
    args: ["--days", "30"]
```

### Parallel Batch Processing (Indexed Job)

```yaml
jobs:
  - name: batch-process
    enabled: true
    completionMode: Indexed
    completions: 10 # Process 10 items
    parallelism: 3 # 3 at a time
    backoffLimitPerIndex: 2
    command: ["python", "process.py", "--index", "$(JOB_COMPLETION_INDEX)"]
```

## Network Policy

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: frontend
        - podSelector:
            matchLabels:
              app: web
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: database
      ports:
        - protocol: TCP
          port: 5432
```

## Advanced Deployment Configuration

```yaml
# Deployment strategy
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0

# Revision and rollback
revisionHistoryLimit: 5
minReadySeconds: 5
progressDeadlineSeconds: 300

# Pod scheduling
priorityClassName: high-priority
terminationGracePeriodSeconds: 60

# DNS configuration
dnsPolicy: ClusterFirst
dnsConfig:
  options:
    - name: ndots
      value: "2"

# Host aliases
hostAliases:
  - ip: "127.0.0.1"
    hostnames:
      - "foo.local"
      - "bar.local"
```

## Immutable ConfigMaps and Secrets

```yaml
configMap:
  enabled: true
  immutable: true # Prevents modifications (k8s 1.21+)
  data:
    config: "production"

secret:
  enabled: true
  immutable: true # Prevents modifications (k8s 1.21+)
  stringData:
    password: "secret"
```

# Common Use Cases

## Microservice Deployment

```yaml
replicaCount: 3
image:
  repository: myorg/api-service
  tag: "v1.2.3"

service:
  type: ClusterIP
  ports:
    - name: http
      port: 80
      targetPort: 8080
    - name: grpc
      port: 9090
      targetPort: 9090

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 20

podDisruptionBudget:
  enabled: true
  minAvailable: 2

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```

## Batch Processing Application

```yaml
replicaCount: 1

jobs:
  - name: daily-report
    schedule: "0 6 * * *"
    timeZone: "America/New_York"
    concurrencyPolicy: Forbid
    command: ["python", "generate_report.py"]
    resources:
      requests:
        cpu: 500m
        memory: 1Gi
```

## Frontend Application with CDN

```yaml
replicaCount: 2
image:
  repository: myorg/frontend
  tag: "v2.0.0"

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  hosts:
    - host: www.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - www.example.com
      secretName: example-tls

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 256Mi
```

# Parameters Reference

For a complete list of all available parameters, see [`values.yaml`](./values.yaml).

Key sections include:

- `image.*` - Image configuration
- `service.*` - Service configuration
- `ingress.*` - Ingress configuration
- `secret.*` / `configMap.*` - Configuration and secrets
- `autoscaling.*` - HPA configuration
- `podDisruptionBudget.*` - PDB configuration
- `networkPolicy.*` - Network policy configuration
- `jobs[]` - Jobs and CronJobs configuration
- `resources.*` - Resource requests and limits
- `*Probe.*` - Health check probes

# Upgrading

## From 0.2.x to 0.3.x

**Breaking Changes:**

- `secret.data` no longer auto-encodes values. Use `secret.stringData` for raw values or manually base64 encode values for `secret.data`.

**Migration Guide:**

**Before (0.2.x):**

```yaml
secret:
  enabled: true
  data:
    PASSWORD: "my-password" # Auto-encoded
```

**After (0.3.x) - Option 1 (Recommended):**

```yaml
secret:
  enabled: true
  stringData:
    PASSWORD: "my-password" # Kubernetes encodes
```

**After (0.3.x) - Option 2:**

```yaml
secret:
  enabled: true
  data:
    PASSWORD: "bXktcGFzc3dvcmQ=" # Manual base64
```

# License

This chart is released under the [MIT License](LICENSE).

# Contributing

Contributions are welcome! Please open an issue or pull request on [GitHub](https://github.com/cabrera-evil/charts).
