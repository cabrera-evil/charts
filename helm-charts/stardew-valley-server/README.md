# Stardew Valley Dedicated Server Helm Chart

Official Helm chart for deploying a Stardew Valley multiplayer dedicated server on Kubernetes.

## TL;DR

```bash
helm repo add cabrera-evil https://cabrera-evil.github.io/charts/
helm install my-stardew cabrera-evil/stardew-valley-server \
  --set gameServer.steamCredentials.username=YOUR_STEAM_USER \
  --set gameServer.steamCredentials.password=YOUR_STEAM_PASS \
  --set gameServer.vncPassword=YOUR_VNC_PASS
```

## Introduction

This chart deploys a Stardew Valley dedicated game server using the [SDVD server image](https://github.com/Sdv-Dev/sdvd).

### Features

- UDP service exposure via LoadBalancer/NodePort
- Persistent game saves and configuration with dual PVC architecture
- Automatic Steam authentication
- Health monitoring with process-based checks
- Resource management and limits
- VNC support for server management
- Backup-friendly dual PVC architecture
- Automatic pod restart on configuration changes

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure
- Steam account that owns Stardew Valley
- For LoadBalancer: Cloud provider with load balancer support

## Installing the Chart

### Basic Installation

```bash
helm install my-stardew cabrera-evil/stardew-valley-server \
  --set gameServer.steamCredentials.username=mysteamuser \
  --set gameServer.steamCredentials.password=mysteampass \
  --set gameServer.vncPassword=myvncpass
```

### Using values file (RECOMMENDED)

Create `my-values.yaml`:

```yaml
gameServer:
  steamCredentials:
    username: "mysteamuser"
    password: "mysteampass"
    guardCode: "AB123"  # If 2FA enabled
  vncPassword: "secure-password"

service:
  type: LoadBalancer

persistence:
  gameData:
    size: 20Gi  # Increase if using mods
```

Install:

```bash
helm install my-stardew cabrera-evil/stardew-valley-server -f my-values.yaml
```

## Configuration

### Required Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `gameServer.steamCredentials.username` | Steam account username | `mysteamuser` |
| `gameServer.steamCredentials.password` | Steam account password | `mypassword` |

### Game Server Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `gameServer.steamCredentials.guardCode` | Steam Guard 2FA code | `""` |
| `gameServer.vncPassword` | VNC access password | `""` |
| `gameServer.disableRendering` | Disable graphics rendering | `"true"` |
| `gameServer.gamePort` | Game server port | `24642` |

### Image Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Container image repository | `sdvd/server` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.tag` | Image tag | `""` (uses appVersion) |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `LoadBalancer` |
| `service.gamePort` | Service port | `24642` |
| `service.protocol` | Service protocol | `UDP` |
| `service.nodePort` | NodePort if service type is NodePort | `""` (auto) |
| `service.externalTrafficPolicy` | External traffic policy | `Local` |
| `service.annotations` | Service annotations | `{}` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.gameData.enabled` | Enable game data persistence | `true` |
| `persistence.gameData.size` | Size of game data PVC | `10Gi` |
| `persistence.gameData.storageClass` | Storage class | `""` (default) |
| `persistence.gameData.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.gameData.annotations` | PVC annotations | `{}` |
| `persistence.serverConfig.enabled` | Enable config persistence | `true` |
| `persistence.serverConfig.size` | Size of config PVC | `1Gi` |
| `persistence.serverConfig.storageClass` | Storage class | `""` (default) |
| `persistence.serverConfig.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.serverConfig.annotations` | PVC annotations | `{}` |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.memory` | Memory request | `2Gi` |
| `resources.requests.cpu` | CPU request | `1000m` |
| `resources.limits.memory` | Memory limit | `4Gi` |
| `resources.limits.cpu` | CPU limit | `2000m` |

### Health Probe Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `livenessProbe.enabled` | Enable liveness probe | `true` |
| `livenessProbe.initialDelaySeconds` | Initial delay | `60` |
| `livenessProbe.periodSeconds` | Check period | `30` |
| `readinessProbe.enabled` | Enable readiness probe | `true` |
| `readinessProbe.initialDelaySeconds` | Initial delay | `30` |
| `startupProbe.enabled` | Enable startup probe | `true` |
| `startupProbe.failureThreshold` | Startup failures allowed | `30` |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `podSecurityContext.fsGroup` | Pod filesystem group | `1000` |
| `securityContext.runAsUser` | Container user ID | `1000` |
| `securityContext.runAsGroup` | Container group ID | `1000` |
| `securityContext.runAsNonRoot` | Run as non-root | `true` |
| `securityContext.readOnlyRootFilesystem` | Read-only root filesystem | `false` |

## Common Use Cases

### Cloud Deployment (AWS/GCP/Azure)

```yaml
service:
  type: LoadBalancer
  annotations:
    # AWS
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    # Azure
    service.beta.kubernetes.io/azure-load-balancer-protocol: "UDP"
    # GCP automatically supports UDP

persistence:
  gameData:
    storageClass: "gp3"  # AWS gp3, or fast-ssd for GCP
    size: 20Gi
  serverConfig:
    storageClass: "gp3"
```

### On-Premise/Bare Metal

```yaml
service:
  type: NodePort
  nodePort: 30642  # Fixed port for firewall rules

persistence:
  gameData:
    storageClass: "local-path"  # or your local storage class
    size: 20Gi
```

### High-Performance Setup

```yaml
resources:
  requests:
    memory: "4Gi"
    cpu: "2000m"
  limits:
    memory: "8Gi"
    cpu: "4000m"

persistence:
  gameData:
    storageClass: "fast-ssd"
    size: 50Gi

nodeSelector:
  disktype: ssd
```

### Multiple Game Servers

Deploy multiple independent servers:

```bash
helm install stardew-farm1 cabrera-evil/stardew-valley-server -f farm1-values.yaml
helm install stardew-farm2 cabrera-evil/stardew-valley-server -f farm2-values.yaml
```

Each server gets its own PVCs and service endpoint.

## Upgrading

### Upgrade Chart Version

```bash
helm repo update
helm upgrade my-stardew cabrera-evil/stardew-valley-server -f my-values.yaml
```

### Update Game Server Image

```bash
helm upgrade my-stardew cabrera-evil/stardew-valley-server \
  --set image.tag=new-version \
  --reuse-values
```

## Backup and Restore

### Manual Backup

```bash
# Get pod name
POD_NAME=$(kubectl get pod -n default -l app.kubernetes.io/name=stardew-valley-server -o jsonpath='{.items[0].metadata.name}')

# Backup game data
kubectl cp default/$POD_NAME:/data/Stardew ./backup-$(date +%Y%m%d)

# Backup server config
kubectl cp default/$POD_NAME:/config/xdg/config/StardewValley ./backup-config-$(date +%Y%m%d)
```

### Restore from Backup

```bash
# Copy backup to pod
kubectl cp ./backup-20240101 default/$POD_NAME:/data/Stardew

# Restart server
kubectl rollout restart deployment/my-stardew
```

### Using Velero for Automated Backups

Tag PVCs for automatic backup:

```yaml
persistence:
  gameData:
    annotations:
      backup.velero.io/backup-volumes: game-data
  serverConfig:
    annotations:
      backup.velero.io/backup-volumes: server-config
```

## Troubleshooting

### Server Won't Start

1. **Check Steam credentials:**
   ```bash
   kubectl logs deployment/my-stardew | grep -i steam
   ```

2. **Verify Steam Guard code** (expires after ~30 seconds)

3. **Ensure Steam account owns Stardew Valley**

4. **Check pod status:**
   ```bash
   kubectl describe pod -l app.kubernetes.io/name=stardew-valley-server
   ```

### Can't Connect to Server

1. **Verify service has external IP:**
   ```bash
   kubectl get svc my-stardew
   ```

2. **Check firewall allows UDP port 24642**

3. **Verify client game version matches server**

4. **Test connectivity:**
   ```bash
   nc -uz <SERVER_IP> 24642
   ```

### Performance Issues

1. **Increase resources:**
   ```yaml
   resources:
     limits:
       memory: "8Gi"
       cpu: "4000m"
   ```

2. **Ensure rendering is disabled:**
   ```yaml
   gameServer:
     disableRendering: "true"
   ```

3. **Check node resources:**
   ```bash
   kubectl top nodes
   kubectl top pods
   ```

### Persistence Issues

1. **Check PVC status:**
   ```bash
   kubectl get pvc
   ```

2. **Verify storage class exists:**
   ```bash
   kubectl get storageclass
   ```

3. **Check PVC events:**
   ```bash
   kubectl describe pvc my-stardew-game-data
   ```

## Uninstalling

```bash
helm uninstall my-stardew
```

**WARNING:** This does NOT delete PVCs by default. To completely remove all data:

```bash
# Delete PVCs
kubectl delete pvc -l app.kubernetes.io/instance=my-stardew

# Or delete specific PVCs
kubectl delete pvc my-stardew-game-data my-stardew-server-config
```

## Security Considerations

- **Credentials**: Store Steam credentials in Kubernetes secrets or use external secret managers (Sealed Secrets, Vault, External Secrets Operator)
- **Network**: Use NetworkPolicy to restrict access if needed
- **Backups**: Regularly backup game data to prevent data loss
- **Updates**: Keep the server image updated for security patches
- **VNC**: Only enable VNC if needed, and use strong passwords

## Advanced Configuration

### Using External Secrets

With [External Secrets Operator](https://external-secrets.io/):

```yaml
# Don't set credentials in values
gameServer:
  steamCredentials:
    username: ""  # Will be injected by ExternalSecret
    password: ""

# Create ExternalSecret separately
```

### Custom Init Containers

Add init containers for mod installation or world setup (modify deployment manually or use Helm post-renderer).

### StatefulSet Alternative

For more advanced scenarios, consider converting to StatefulSet (requires manual customization).

## License

This chart is licensed under the MIT License.

## Maintainers

- Douglas Cabrera (contact@cabrera-dev.com)

## Sources

- **Chart Source**: https://github.com/cabrera-evil/charts
- **SDVD Project**: https://github.com/Sdv-Dev/sdvd
- **Stardew Valley**: https://www.stardewvalley.net/

## Contributing

Contributions are welcome! Please open an issue or pull request at the GitHub repository.
