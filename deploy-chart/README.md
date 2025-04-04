# deploy-chart

This Helm chart is a generic template for deploying applications in a Kubernetes cluster. It includes templates for core Kubernetes resources such as deployments, services, ingress, secrets, and more. The chart is designed to be customizable for different applications.

## 📦 Table of Contents

- [deploy-chart](#deploy-chart)
  - [📦 Table of Contents](#-table-of-contents)
  - [📦 Overview](#-overview)
  - [🚀 Quick Start](#-quick-start)
  - [🛠️ Configuration](#️-configuration)
    - [Example configuration values](#example-configuration-values)
    - [Additional Customization](#additional-customization)
    - [Overrides](#overrides)
  - [🧪 Testing](#-testing)
  - [⚙️ `runner.sh` Script](#️-runnersh-script)
    - [Available commands in `runner.sh`](#available-commands-in-runnersh)
    - [Example usage](#example-usage)
  - [📄 License](#-license)

## 📦 Overview

The `deploy-chart` includes the following features:

- Kubernetes **Deployments** for scalable application pods
- **Service** and **Ingress** resources for external and internal access
- **ConfigMap** and **Secrets** for configuration and sensitive data management
- **Horizontal Pod Autoscaling (HPA)** for automatic scaling based on resource usage
- **Resource management** (CPU and Memory limits/requests)
- **Probes** (Liveness/Readiness) to ensure application health
- **ServiceAccount** support for RBAC

## 🚀 Quick Start

To deploy this Helm chart, follow these steps:

1. **Add the Helm repository**:

    ```bash
    helm repo add cabrera-evil https://cabrera-evil.github.io/charts/
    helm repo update
    ```

2. **Install the chart**:

    ```bash
    helm install <release-name> cabrera-evil/deploy-chart
    ```

3. **Upgrade the chart** (if needed):

    ```bash
    helm upgrade <release-name> cabrera-evil/deploy-chart
    ```

4. **Uninstall the chart**:

    ```bash
    helm uninstall <release-name>
    ```

## 🛠️ Configuration

The `values.yaml` file provides default configuration values for the chart, which you can override when installing or upgrading.

### Example configuration values

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
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
```

### Additional Customization

- **Secrets and ConfigMaps**: You can define sensitive data and application configuration using the `secret` and `configMap` settings.
- **Resource Limits**: Define CPU and memory resource requests/limits for your pods.

### Overrides

To override default values, create a custom `values.yaml` or specify them directly via `helm install` or `helm upgrade`:

```bash
helm install <release-name> cabrera-evil/deploy-chart -f custom-values.yaml
```

## 🧪 Testing

This chart includes a test file under `templates/tests/test-connection.yaml`, which is used to validate the connection to the deployed application.

To test the deployment:

```bash
kubectl apply -f templates/tests/test-connection.yaml
```

## ⚙️ `runner.sh` Script

The `runner.sh` script helps automate Helm chart commands such as installation, upgrade, and status checks. You can use it to simplify interactions with your Kubernetes cluster.

### Available commands in `runner.sh`

- `install`: Install the Helm chart with the specified options.
- `upgrade`: Upgrade an existing release of the chart.
- `uninstall`: Uninstall the Helm release.
- `logs`: Tail logs from the deployed pod.
- `describe`: Describe the main pod in the release.
- `status`: Check the status of the Helm release.

### Example usage

```bash
./runner.sh install --stage dev
./runner.sh upgrade --values values.production.yaml
./runner.sh logs -r deploy-chart
```

## 📄 License

This Helm chart is licensed under the [MIT License](LICENSE).

---

© 2025 Douglas Cabrera · [cabrera-dev.com](https://cabrera-dev.com)
