<!--

********************************************************************************

WARNING:

    DO NOT EDIT "DEVELOPMENT.md" UNLESS YOU ARE MODIFYING LOCAL TOOLING
    OR CONTRIBUTING TO CHART LOGIC

********************************************************************************

-->

# Development guide

This document outlines how to develop, lint, and package Helm charts locally for the `cabrera-evil/charts` repository.

## Prerequisites

Ensure you have the following tools installed:

- Helm 3.x
- Git
- GNU Make (optional)
- A POSIX-compatible shell

## Lint a chart

To verify that a chart follows Helm's best practices:

```bash
helm lint <chart-name>
```

## Package a chart

To generate a `.tgz` archive:

```bash
helm package <chart-name>
```

The package will be output in the current directory.

## Serve charts locally

For local testing, you can serve the chart repository:

```bash
helm repo serve
```

You can then install from `http://localhost:8879/charts`.

## Update the GitHub Pages index

If you are publishing new charts or updating versions:

```bash
helm repo index . --url https://cabrera-evil.github.io/charts/
```

Make sure to commit the updated `index.yaml`.

## Contribution guidelines

- Ensure each chart contains a valid `Chart.yaml` and `README.md`.
- Keep versioning consistent with [SemVer](https://semver.org/).
- Prefer `values.yaml`-based configuration over hardcoding.
- Validate templates using `helm template` for expected output.
- All new charts or major changes must go through pull requests with review.
