# GitHub Actions Workflows

This directory contains automated CI/CD workflows for the Helm charts repository.

**✨ All workflows are dynamic and automatically discover charts in the repository!**

Adding a new chart? Just create it in the repository root (e.g., `new-chart/`) and the workflows will automatically handle testing and releasing.

## Workflows

### 1. Lint and Test (`workflows/lint-test.yaml`)

**Triggers:** Pull requests and pushes to master that modify any chart files (`*/Chart.yaml`, `*/values.yaml`, `*/templates/**`)

**Purpose:** Validate quality and functionality of ALL modified charts

**How it works:**
1. Automatically discovers all charts in the repository
2. Identifies which charts have been modified
3. Runs comprehensive tests on each chart

**Steps (per chart):**
- Lint with `helm lint` and `chart-testing`
- Validate Chart.yaml metadata completeness
- Validate SemVer version format
- Test template rendering (basic + all features enabled)
- Validate values.schema.json (if present)
- Security scan with Trivy
- Install test in Kind cluster (for changed charts)

**Why:** Ensures all charts meet quality standards before merging, scales to N charts automatically

---

### 2. PR Version Check (`workflows/pr-check.yaml`)

**Triggers:** Pull requests that modify any chart files

**Purpose:** Enforce version bumping for ALL modified charts

**How it works:**
1. Automatically detects all modified charts (Chart.yaml changes OR template/values changes)
2. Compares versions for each chart against base branch
3. Creates a summary table showing each chart's status
4. Fails if any chart wasn't version bumped

**Output:**
- Comments on PR with table showing version status for each chart
- Clear instructions on how to fix version bump issues

**Why:** Prevents forgetting to bump versions for any chart, scales to N charts automatically

---

### 3. Release (`workflows/release.yaml`)

**Triggers:** Pushes to master that modify any `*/Chart.yaml` file

**Purpose:** Automatically publish releases for ALL modified charts

**How it works:**
1. **Detect phase:** Identifies which Chart.yaml files changed
2. **Matrix strategy:** Creates parallel release jobs for each chart
3. **Release phase (per chart):**
   - Check if version already released (skip if yes)
   - Lint and package the chart
   - Generate changelog from git commits for that chart
   - Create GitHub release with tag `<chart-name>-X.Y.Z`
   - Publish `.tgz` to GitHub Pages
   - Update Helm repository index (merged, not overwritten)

**Output:**
- Separate GitHub release for each chart
- Tags like `deploy-chart-0.2.0`, `my-app-1.0.0`, etc.
- Unified Helm repository index with all charts

**Why:** Eliminates manual release process, handles multiple charts in one push, ensures consistency

---

## Configuration

### Chart Testing (`ct.yaml`)

Configuration for the `chart-testing` tool:
- **Auto-discovery:** Searches from repository root for all charts
- **Target branch:** `master`
- **Validation:** Version increments, maintainer info, chart schema
- **Testing:** Only tests changed charts (not all)
- **Dependencies:** Includes Bitnami repo for common dependencies

## Required Secrets/Permissions

The workflows require these permissions (configured in workflow files):

- `contents: write` - For creating releases and pushing to gh-pages
- `pages: write` - For publishing to GitHub Pages
- `id-token: write` - For GitHub Pages deployment

**Note:** `GITHUB_TOKEN` is automatically provided by GitHub Actions.

## Setup Requirements

1. **Enable GitHub Pages:**
   - Go to repository Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages` / `(root)`
   - Save

2. **Create gh-pages branch** (if it doesn't exist):
   ```bash
   git checkout --orphan gh-pages
   git reset --hard
   git commit --allow-empty -m "Initialize gh-pages"
   git push origin gh-pages
   git checkout master
   ```

3. **Set repository permissions:**
   - Settings → Actions → General → Workflow permissions
   - Select "Read and write permissions"
   - Check "Allow GitHub Actions to create and approve pull requests"

## Workflow Outputs

### Lint and Test
- ✅ All validation checks passed
- 📊 Test coverage summary
- 🔒 Security scan results

### PR Version Check
- 💬 Comment on PR with version bump status
- 📋 Summary in PR checks

### Release
- 📦 Chart package (.tgz) in GitHub Releases
- 🏷️ Git tag for the release
- 📝 Auto-generated changelog
- 🚀 Updated Helm repository index
- 📊 Release summary with installation instructions

## Local Testing

Test workflows locally before pushing:

```bash
# Lint all charts
for chart in */Chart.yaml; do
  chart_dir=$(dirname "$chart")
  helm lint "$chart_dir"
done

# Lint specific chart
helm lint my-chart

# Validate with chart-testing (auto-discovers charts)
ct lint --target-branch master

# Test template rendering
helm template test my-chart

# Security scan
trivy config my-chart
```

## Troubleshooting

**Release workflow didn't trigger:**
- Check that Chart.yaml was modified in the push
- Verify version is new (not already released)
- Check workflow run in Actions tab

**Version check fails on PR:**
- Ensure you bumped the version in Chart.yaml
- Version must follow SemVer (X.Y.Z format)
- Commit the Chart.yaml change

**Pages deployment fails:**
- Verify gh-pages branch exists
- Check repository permissions
- Ensure Pages is enabled in repository settings

## Adding a New Chart

The workflows automatically handle new charts! Just:

1. Create a new directory in repository root (e.g., `my-app/`)
2. Add standard Helm chart structure:
   ```
   my-app/
   ├── Chart.yaml
   ├── values.yaml
   ├── templates/
   │   └── ...
   └── README.md (optional)
   ```
3. Commit and push - workflows automatically discover and test it!

## Best Practices

1. **Always bump version** when modifying chart files
2. **Follow SemVer** for version increments (per chart)
3. **Test locally** before pushing
4. **Review CI results** before merging PRs
5. **Keep Chart.yaml metadata** up to date for all charts
6. **Add descriptive commit messages** (used in per-chart changelogs)
7. **One chart per directory** in repository root
