# Cabrera Evil Helm Charts

This repository contains a curated collection of Helm charts maintained by [Douglas Cabrera](https://cabrera-dev.com), designed for scalable, secure, and production-grade Kubernetes deployments.

## 📦 Table of Contents

- [Cabrera Evil Helm Charts](#cabrera-evil-helm-charts)
  - [📦 Table of Contents](#-table-of-contents)
  - [🚀 Getting Started](#-getting-started)
  - [📦 Available Charts](#-available-charts)
  - [🛠️ Local Development](#️-local-development)
  - [🌍 GitHub Pages Integration](#-github-pages-integration)
  - [📄 License](#-license)

## 🚀 Getting Started

1. **Add the repository to your Helm client**

    ```bash
    helm repo add cabrera-evil https://cabrera-evil.github.io/charts/
    ```

2. **Update the Helm repository cache**

    ```bash
    helm repo update
    ```

3. **Install a chart**

    ```bash
    helm install <release-name> cabrera-evil/<chart-name> [flags]
    ```

## 📦 Available Charts

| Chart Name                         | Description                           | Version |
| ---------------------------------- | ------------------------------------- | ------- |
| **[deploy-chart](./deploy-chart)** | Generic Helm chart for app deployment | 0.1.0   |
| *(More coming soon)*               | *(Chart details will be listed here)* | -       |

> ℹ️ Each chart includes its own `README.md` for configuration and usage details.

## 🛠️ Local Development

1. **Lint a chart**

    ```bash
    helm lint charts/<chart-name>
    ```

2. **Package a chart**

    ```bash
    helm package charts/<chart-name>
    ```

3. **Serve charts locally**

    ```bash
    helm repo serve
    ```

## 🌍 GitHub Pages Integration

This repository uses GitHub Pages to host the Helm chart index.

1. **Update the chart index**

```bash
helm repo index . --url https://cabrera-evil.github.io/charts/
```

## 📄 License

This Helm chart is licensed under the [MIT License](LICENSE).

---

© 2025 Douglas Cabrera · [cabrera-dev.com](https://cabrera-dev.com)
