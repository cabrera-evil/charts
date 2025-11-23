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

## Versioning workflow

The chart version in `Chart.yaml` is **NOT automatically updated**. You must manually increment it before publishing.

**SemVer guidelines:**

- Patch (0.2.0 → 0.2.1): Bug fixes, minor improvements
- Minor (0.2.0 → 0.3.0): New features, backward compatible
- Major (0.2.0 → 1.0.0): Breaking changes

**Before publishing:**

1. Edit `Chart.yaml` and increment `version`
2. Update `appVersion` if the default app version changes
3. Run `helm lint <chart-name>`
4. Run `helm package <chart-name>`
5. Update repository index

## Managing dependencies

If your chart depends on other charts, add them to `Chart.yaml`:

```yaml
dependencies:
  - name: redis
    version: 17.11.3
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
```

Then run:

```bash
helm dependency update <chart-name>
```

This generates:

- `Chart.lock` - Lockfile with exact versions and checksums
- `charts/` directory - Downloaded dependency `.tgz` files

**Note:** `deploy-chart` currently has no dependencies, so no `Chart.lock` is needed.

## Automated CI/CD

This repository uses GitHub Actions to automate chart testing, validation, and publishing.

### Workflows

#### 1. Release (`release.yaml`)

Runs when `Chart.yaml` is modified on master. Automatically:

- 📦 Packages the chart
- 🏷️ Creates a GitHub release with tag `deploy-chart-X.Y.Z`
- 📝 Generates changelog from git commits
- 🚀 Publishes to GitHub Pages
- 📊 Updates the Helm repository index

### Release Process (Automated)

1. **Make changes** to chart templates or values
2. **Bump version** in `helm-charts/deploy-chart/Chart.yaml`
   ```bash
   vim helm-charts/deploy-chart/Chart.yaml
   # Change: version: 0.2.0 → version: 0.3.0
   ```
3. **Create PR** - CI will validate changes and check version bump
4. **Merge PR** - Chart is automatically released!

The release workflow will:

- Create tag `deploy-chart-0.3.0`
- Create GitHub release with changelog
- Publish to https://cabrera-evil.github.io/charts/
- Make chart immediately available via `helm repo update`

### Manual Release (Not Recommended)

If you need to release manually:

```bash
# 1. Bump version in Chart.yaml
vim helm-charts/deploy-chart/Chart.yaml

# 2. Lint and package
helm lint helm-charts/deploy-chart
helm package helm-charts/deploy-chart

# 3. Update index (if you have gh-pages checked out)
helm repo index . --url https://cabrera-evil.github.io/charts/

# 4. Commit and push
git add .
git commit -m "chore: release deploy-chart X.Y.Z"
git push
```

**Note:** Manual releases should be avoided. The automated workflow ensures consistency and proper versioning.

## Contribution guidelines

- Ensure each chart contains a valid `Chart.yaml` and `README.md`.
- Keep versioning consistent with [SemVer](https://semver.org/).
- **Always bump the chart version** when modifying templates or values.
- Prefer `values.yaml`-based configuration over hardcoding.
- Validate templates using `helm template` for expected output.
- All new charts or major changes must go through pull requests with review.
- CI workflows must pass before merging.
