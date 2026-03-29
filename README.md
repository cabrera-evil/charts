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

| Chart Name                                                       | Description                                                                                                         | Version | App Version | Kubernetes |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ------- | ----------- | ---------- |
| **[deploy-chart](./helm-charts/deploy-chart)**                   | Production-ready generic Helm chart for deploying containerized applications with comprehensive Kubernetes features | 0.3.0   | latest      | >=1.19.0   |
| **[stardew-valley-server](./helm-charts/stardew-valley-server)** | Dedicated game server for Stardew Valley multiplayer with persistent storage and VNC support                        | 0.1.0   | latest      | >=1.19.0   |

> Each chart includes a dedicated `README.md` with comprehensive usage instructions, configuration examples, and complete parameter reference.

# License

This project is released under the [MIT License](https://github.com/cabrera-evil/charts/blob/master/LICENSE).
