# OpenClaw Helm Chart

Helm chart for deploying [OpenClaw](https://github.com/openclaw/openclaw) — an AI gateway and agent platform — on Kubernetes.

## TL;DR

```bash
helm repo add cabrera-evil https://cabrera-evil.github.io/charts/
helm install my-openclaw cabrera-evil/openclaw \
  --set secret.anthropicApiKey=sk-ant-... \
  --set secret.gatewayToken=my-secret-token
```

Then access the Control UI:

```bash
kubectl port-forward svc/my-openclaw 18789:18789
open http://localhost:18789
```

## Introduction

This chart deploys OpenClaw in a single pod with a ConfigMap-managed configuration, a persistent volume for agent state, and an optional secret for provider API keys and gateway authentication. It follows the security and scalability conventions established in the Cabrera Evil charts collection.

### Features

- Configurable gateway bind (`loopback` for port-forward, `0.0.0.0` for Ingress/LoadBalancer)
- Persistent storage for agent state and conversation memory
- ConfigMap-driven `openclaw.json` and `AGENTS.md` — no image rebuilds needed
- Secret injection for provider API keys (Anthropic, Gemini, OpenAI, OpenRouter)
- Automatic rolling updates on config or secret changes (checksum annotations)
- Startup, liveness, and readiness probes with a 2-minute startup window
- Optional HPA, PodDisruptionBudget, and NetworkPolicy for production HA deployments
- Hard validation guard — Ingress is blocked when `gateway.bind=loopback`
- Zero-downtime rolling strategy (`maxUnavailable: 0`) by default
- Full security hardening: `readOnlyRootFilesystem`, `drop: ALL`, non-root UID 1000

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure
- API key for at least one model provider (Anthropic, Gemini, OpenAI, or OpenRouter)

## Installing the Chart

### Quick install (port-forward access)

```bash
helm install my-openclaw cabrera-evil/openclaw \
  --set secret.anthropicApiKey=sk-ant-... \
  --set secret.gatewayToken=my-secret-token
```

### Using a values file (recommended)

Create `my-values.yaml`:

```yaml
secret:
  gatewayToken: "my-secret-token"
  anthropicApiKey: "sk-ant-..."

persistence:
  size: 20Gi

resources:
  requests:
    cpu: 250m
    memory: 512Mi
  limits:
    cpu: 1000m
    memory: 1Gi
```

Install:

```bash
helm install my-openclaw cabrera-evil/openclaw -f my-values.yaml
```

### Retrieve the gateway token after install

```bash
kubectl get secret my-openclaw-secret \
  -o jsonpath='{.data.OPENCLAW_GATEWAY_TOKEN}' | base64 -d
```

## Configuration

### Gateway Configuration

| Parameter            | Description                                        | Default    |
| -------------------- | -------------------------------------------------- | ---------- |
| `gateway.bind`       | Gateway bind address (`loopback` or `0.0.0.0`)     | `loopback` |
| `gateway.port`       | Gateway port                                       | `18789`    |
| `gateway.tokenAuth`  | Enable token-based auth for the Control UI         | `true`     |
| `extraGatewayConfig` | Additional keys merged into `openclaw.json`        | `{}`       |
| `agentsConfig`       | Content of `AGENTS.md` injected into the ConfigMap | See values |

### Secret / API Keys

| Parameter                 | Description                     | Default |
| ------------------------- | ------------------------------- | ------- |
| `secret.enabled`          | Create the provider keys Secret | `true`  |
| `secret.gatewayToken`     | Control UI authentication token | `""`    |
| `secret.anthropicApiKey`  | Anthropic API key               | `""`    |
| `secret.geminiApiKey`     | Google Gemini API key           | `""`    |
| `secret.openaiApiKey`     | OpenAI API key                  | `""`    |
| `secret.openrouterApiKey` | OpenRouter API key              | `""`    |

Only non-empty keys are written into the Secret — unused providers leave no empty env vars.

### Image Configuration

| Parameter          | Description                                | Default                     |
| ------------------ | ------------------------------------------ | --------------------------- |
| `image.repository` | Container image repository                 | `ghcr.io/openclaw/openclaw` |
| `image.pullPolicy` | Image pull policy                          | `IfNotPresent`              |
| `image.tag`        | Image tag (defaults to chart `appVersion`) | `""`                        |

### Persistence Configuration

| Parameter                  | Description                               | Default          |
| -------------------------- | ----------------------------------------- | ---------------- |
| `persistence.enabled`      | Enable persistent storage for agent state | `true`           |
| `persistence.size`         | PVC size                                  | `10Gi`           |
| `persistence.storageClass` | Storage class (empty = cluster default)   | `""`             |
| `persistence.accessMode`   | PVC access mode                           | `ReadWriteOnce`  |
| `persistence.mountPath`    | Mount path inside the container           | `/home/openclaw` |

### Service Configuration

| Parameter             | Description             | Default     |
| --------------------- | ----------------------- | ----------- |
| `service.type`        | Kubernetes service type | `ClusterIP` |
| `service.port`        | Service port            | `18789`     |
| `service.annotations` | Service annotations     | `{}`        |

### Ingress Configuration

| Parameter             | Description                 | Default                         |
| --------------------- | --------------------------- | ------------------------------- |
| `ingress.enabled`     | Enable Ingress              | `false`                         |
| `ingress.className`   | Ingress class name          | `traefik`                       |
| `ingress.annotations` | Ingress annotations         | Traefik + cert-manager defaults |
| `ingress.hosts`       | Ingress hostnames and paths | `openclaw.local /`              |
| `ingress.tls`         | TLS configuration           | See values                      |

> **Note:** `ingress.enabled=true` requires `gateway.bind=0.0.0.0`. The chart will fail with a clear error if this constraint is violated.

### Health Probe Configuration

| Parameter                            | Description                           | Default |
| ------------------------------------ | ------------------------------------- | ------- |
| `livenessProbe.enabled`              | Enable liveness probe                 | `true`  |
| `livenessProbe.initialDelaySeconds`  | Initial delay                         | `10`    |
| `livenessProbe.periodSeconds`        | Check interval                        | `15`    |
| `livenessProbe.failureThreshold`     | Failures before restart               | `3`     |
| `readinessProbe.enabled`             | Enable readiness probe                | `true`  |
| `readinessProbe.initialDelaySeconds` | Initial delay                         | `5`     |
| `startupProbe.enabled`               | Enable startup probe                  | `true`  |
| `startupProbe.failureThreshold`      | Max failures (24 × 5s = 2 min window) | `24`    |

### Security Configuration

| Parameter                                  | Description                  | Default |
| ------------------------------------------ | ---------------------------- | ------- |
| `podSecurityContext.fsGroup`               | Filesystem group for the pod | `1000`  |
| `securityContext.runAsUser`                | Container UID                | `1000`  |
| `securityContext.runAsGroup`               | Container GID                | `1000`  |
| `securityContext.runAsNonRoot`             | Enforce non-root execution   | `true`  |
| `securityContext.readOnlyRootFilesystem`   | Read-only root filesystem    | `true`  |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation   | `false` |

### Autoscaling Configuration

| Parameter                                       | Description      | Default |
| ----------------------------------------------- | ---------------- | ------- |
| `autoscaling.enabled`                           | Enable HPA       | `false` |
| `autoscaling.minReplicas`                       | Minimum replicas | `1`     |
| `autoscaling.maxReplicas`                       | Maximum replicas | `5`     |
| `autoscaling.targetCPUUtilizationPercentage`    | CPU target       | `80`    |
| `autoscaling.targetMemoryUtilizationPercentage` | Memory target    | `80`    |

### High Availability Configuration

| Parameter                          | Description            | Default |
| ---------------------------------- | ---------------------- | ------- |
| `podDisruptionBudget.enabled`      | Enable PDB             | `false` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1`     |
| `networkPolicy.enabled`            | Enable NetworkPolicy   | `false` |

## Common Use Cases

### Local development (port-forward)

Default configuration — no changes needed:

```bash
helm install openclaw cabrera-evil/openclaw \
  --set secret.anthropicApiKey=sk-ant-...

kubectl port-forward svc/openclaw 18789:18789
open http://localhost:18789
```

### Expose via Ingress (HTTPS with cert-manager)

```yaml
gateway:
  bind: "0.0.0.0"

ingress:
  enabled: true
  className: traefik
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
  hosts:
    - host: openclaw.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - openclaw.example.com
      secretName: openclaw-tls

secret:
  gatewayToken: "your-strong-token"
  anthropicApiKey: "sk-ant-..."
```

### Multi-provider setup

```yaml
secret:
  gatewayToken: "your-strong-token"
  anthropicApiKey: "sk-ant-..."
  openaiApiKey: "sk-..."
  geminiApiKey: "AI..."
```

### High availability deployment

```yaml
replicaCount: 3

# Requires ReadWriteMany storage class for shared persistent state
persistence:
  accessMode: ReadWriteMany
  storageClass: efs # or nfs, azureblob, etc.

podDisruptionBudget:
  enabled: true
  minAvailable: 2

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          topologyKey: kubernetes.io/hostname
          labelSelector:
            matchLabels:
              app.kubernetes.io/name: openclaw
```

### Custom agent instructions

```yaml
agentsConfig: |
  # My OpenClaw Agents

  You are a helpful assistant specialized in internal tooling.
  Always respond in the user's language.

  ## Available Skills
  - code-review
  - documentation
```

### Add extra gateway config

```yaml
extraGatewayConfig:
  logLevel: debug
  maxConcurrentSessions: 20
```

### Using an existing secret (External Secrets / Sealed Secrets)

Disable the chart-managed secret and reference your own:

```yaml
secret:
  enabled: false

envFrom:
  - secretRef:
      name: my-existing-openclaw-secret
```

## Customization

### Pin a specific OpenClaw version

```yaml
image:
  tag: "1.2.3" # see https://github.com/openclaw/openclaw/releases
```

### Custom storage class

```yaml
persistence:
  storageClass: "fast-nvme"
  size: 50Gi
```

### Add provider keys after install (patch secret directly)

```bash
kubectl patch secret my-openclaw-secret \
  -p '{"stringData":{"OPENAI_API_KEY":"sk-..."}}'
kubectl rollout restart deployment/my-openclaw
```

## Upgrading

```bash
helm repo update
helm upgrade my-openclaw cabrera-evil/openclaw -f my-values.yaml
```

Config and secret changes automatically trigger a rolling restart via checksum annotations — no manual rollout needed when values change.

## Troubleshooting

### Pod is not starting

```bash
kubectl describe pod -l app.kubernetes.io/name=openclaw
kubectl logs deployment/my-openclaw
```

### Health check failing

Verify the gateway is reachable on `/health`:

```bash
kubectl port-forward svc/my-openclaw 18789:18789
curl http://localhost:18789/health
```

### Ingress returns connection refused

Ensure `gateway.bind` is set to `0.0.0.0` — the loopback bind is not reachable by ingress controllers. The chart will reject this configuration at render time.

### PVC not binding

```bash
kubectl get pvc
kubectl describe pvc my-openclaw-data
kubectl get storageclass
```

### Check rendered configuration

```bash
kubectl get configmap my-openclaw-config -o yaml
kubectl exec deploy/my-openclaw -- cat /etc/openclaw/openclaw.json
```

## Uninstalling

```bash
helm uninstall my-openclaw
```

**Note:** The PVC is not deleted automatically. To remove all data:

```bash
kubectl delete pvc my-openclaw-data
```

## Security Considerations

- Keep `gateway.tokenAuth: true` and set a strong `secret.gatewayToken` in production
- Use External Secrets Operator or Sealed Secrets to avoid storing API keys in plain-text values files
- Enable `networkPolicy` to restrict egress to only the model provider endpoints you use
- Use HTTPS (Ingress + TLS) when binding to `0.0.0.0` — never expose the loopback gateway directly
- The chart enforces non-root execution, read-only root filesystem, and dropped Linux capabilities by default

## Parameters Reference

For a full list of parameters see [`values.yaml`](./values.yaml).

Key sections:

- `gateway.*` — Gateway bind, port, and token auth
- `agentsConfig` — AGENTS.md content
- `extraGatewayConfig` — Extra openclaw.json keys
- `secret.*` — Provider API keys and gateway token
- `persistence.*` — Persistent volume for agent state
- `service.*` — Kubernetes service
- `ingress.*` — Ingress (requires `gateway.bind=0.0.0.0`)
- `autoscaling.*` — HPA configuration
- `podDisruptionBudget.*` — PDB for HA
- `networkPolicy.*` — Network isolation
- `*Probe.*` — Liveness, readiness, and startup probes

## License

This chart is licensed under the MIT License.

## Maintainers

- Douglas Cabrera (<contact@cabrera-dev.com>)

## Sources

- **Chart Source**: <https://github.com/cabrera-evil/charts/tree/master/helm-charts/openclaw>
- **OpenClaw Project**: <https://github.com/openclaw/openclaw>
- **OpenClaw Docs**: <https://docs.openclaw.ai>
