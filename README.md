<!--

********************************************************************************

WARNING:

    DO NOT EDIT "charts/README.md"

    IT IS PARTIALLY AUTO-GENERATED

    (based on chart directories, Chart.yaml files, and Helm metadata)

********************************************************************************

-->

# Quick reference

- **Maintained by**:  
  [Douglas Cabrera](https://cabrera-dev.com)

- **Where to get help**:  
  [GitHub Issues](https://github.com/cabrera-evil/charts/issues)

# What is this repository?

**Cabrera Evil Helm Charts** is a curated collection of Helm charts maintained by [Douglas Cabrera](https://github.com/cabrera-evil), designed for scalable, secure, and production-grade Kubernetes deployments. Each chart is versioned, configurable, and follows Helm best practices to ensure compatibility and maintainability across environments.

# How to use this repository

## Add the repository to your Helm client

```bash
helm repo add cabrera-evil https://cabrera-evil.github.io/charts/
```

## Update your local Helm cache

```bash
helm repo update
```

## Install a chart

```bash
helm install <release-name> cabrera-evil/<chart-name> [flags]
```

> Use `--values <file.yaml>` or `--set key=value` to override configuration options.

# Available charts

| Chart Name                         | Description                           | Version |
| ---------------------------------- | ------------------------------------- | ------- |
| **[deploy-chart](./helm-charts/deploy-chart)** | Generic Helm chart for app deployment | 0.2.0   |
| _(More coming soon)_               | _(Chart details will be listed here)_ | -       |

> Each chart includes a dedicated `README.md` with usage instructions and configurable parameters.

# License

This project is released under the [MIT License](https://github.com/cabrera-evil/charts/blob/master/LICENSE).
