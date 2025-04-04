# Cabrera Evil Helm Charts

This repository contains a curated collection of Helm charts maintained by [Douglas Cabrera](https://cabrera-dev.com), designed for scalable, secure, and production-grade Kubernetes deployments.

## 🚀 Getting Started

Add the repository to your Helm client:

```bash
helm repo add cabrera-evil https://cabrera-evil.github.io/charts/
helm repo update
```

Install a chart:

```bash
helm install <release-name> cabrera-evil/<chart-name> [flags]
```

## 📦 Available Charts

| Chart Name                                | Description                           | Version |
| ----------------------------------------- | ------------------------------------- | ------- |
| **[deploy-chart](./charts/deploy-chart)** | Generic Helm chart for app deployment | 0.1.0   |
| *(More coming soon)*                      | *(Chart details will be listed here)* | -       |

> ℹ️ Each chart includes its own `README.md` for configuration and usage details.

## 🛠️ Local Development

Lint and package charts:

```bash
helm lint charts/<chart-name>
helm package charts/<chart-name>
```

Serve charts locally:

```bash
helm repo serve
```

## 🌍 GitHub Pages Integration

This repository uses GitHub Pages to host the Helm chart index. Charts are published under the `gh-pages` branch.

Update the index after packaging:

```bash
helm repo index ./charts --url https://cabrera-evil.github.io/charts/
git add .
git commit -m "chore: update chart index"
git push origin gh-pages
```

---

© 2025 Douglas Cabrera · [cabrera-dev.com](https://cabrera-dev.com)