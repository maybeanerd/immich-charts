# Disclaimer

This is a fork from the [official immich-charts](https://github.com/immich-app/immich-charts) repo. The aim is to provide a better developer experience, more granular releases (including all immich versions), and a more comprehensive chart (including database, e.g.)

It was created based on the discussions in the following issue: https://github.com/immich-app/immich-charts/issues/68#issuecomment-2291250875

THIS IS A WIP.

Do not use this in production. It's a true [zero-ver](https://semver.org/#spec-item-4), which means every other release might include breaking changes.

Feel free to play around with it. Please try and test it. Breaking changes will be marked in release notes, so please keep an eye out for them when updating version.

# Immich Helm Chart

Installs [Immich](https://github.com/immich-app/immich), a self-hosted photo and video backup solution, on Kubernetes.

This chart leverages the [bjw-s common-library](https://github.com/bjw-s-labs/helm-charts/tree/common-4.3.0/charts/library/common) to make configuration as easy as possible while providing enterprise-grade flexibility.

## Installation

```bash
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f your-values.yaml
```

**Important**: Do not copy the full `values.yaml` from this repository. Only set the values you want to override.

## Configuration Guide

### What You MUST Configure

Before deploying Immich, you **must** configure:

**Database Password** - Set a secure password when using bundled PostgreSQL:
- `immich.database.password` - Direct password value
- Or use `immich.database.password.valueFrom.secretKeyRef` for existing secrets

> **Note**: If your cluster doesn't have a default StorageClass, you'll also need to set storage classes for all persistent volumes (see "Storage Configuration" below).

### What You Might Want to Configure

Common customizations based on your deployment needs:

#### Basic Configuration
- **Storage Configuration**:
  - **Storage Classes** - Override default StorageClass if needed (`persistence.*.storageClass`, `postgresql.primary.persistence.storageClass`)
  - **Storage Sizes** - Adjust volume sizes based on your needs (`persistence.*.size`)
- **Database Storage Type** - Optimize for SSD storage (`immich.database.storageType: ssd`)
- **Ingress** - Optionally enable ingress for web access (`ingress.server.enabled: true`). Disabled by default - access via port-forward or LoadBalancer service

#### Resource Management
- **Machine Learning** - Disable to save resources (`immich.machineLearning.enabled: false`)
- **Resource Limits** - Set CPU/memory for workloads (`controllers.*.resources`)

#### External Services
- **External Database** - Use managed PostgreSQL (`postgresql.enabled: false`, configure `immich.database.*`)
- **External Redis** - Use managed Redis (`redis.enabled: false`, configure `immich.redis.*`)

#### Advanced Features
- **Application Configuration** - Manage Immich settings via config file (`immich.configuration`)
- **Monitoring** - Enable Prometheus metrics (`immich.monitoring.enabled`)
- **GPU Acceleration** - Add GPU resources for ML (`controllers.machine-learning.resources.limits`)

### Configuration Examples

We provide tested examples for common deployment scenarios:

- **[minimal.yaml](charts/immich/examples/minimal.yaml)** - Basic setup with bundled PostgreSQL and Redis (best for getting started)
- **[minimal-external.yaml](charts/immich/examples/minimal-external.yaml)** - Minimal deployment using external services (PostgreSQL, Redis) with ML disabled
- **[full-features.yaml](charts/immich/examples/full-features.yaml)** - Advanced configuration showcasing most optional features (SSD optimization, custom config, secrets, ingress, pod affinity, resource limits)

Deploy an example:
```bash
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/minimal.yaml
```

⚠️ **Important**: Examples use placeholder values. Update passwords, storage classes, sizes, and hostnames before production use.

## Key Configuration Reference

### Application Configuration (`immich.configuration`)

Controls how Immich application settings are managed:

- **`{}` (empty object, recommended)** - Enables config file with Immich defaults. Best for GitOps/declarative deployments.
- **`null`** - No config file. All settings managed via Immich web GUI and stored in database.
- **Custom values** - Provide specific settings that override Immich defaults. See [custom-config.yaml](charts/immich/examples/custom-config.yaml).

For available settings, see the [Immich configuration documentation](https://immich.app/docs/install/config-file/).

### Database Storage Type (`immich.database.storageType`)

Set to `ssd` or `hdd` to optimize PostgreSQL for your storage:

```yaml
immich:
  database:
    storageType: ssd  # or 'hdd' (default)
```

This automatically configures PostgreSQL environment variables for optimal performance. See [ssd-optimized.yaml](charts/immich/examples/ssd-optimized.yaml) for a complete example.

### External Services

To use external/managed services instead of bundled ones:

1. Disable the bundled service: `postgresql.enabled: false` and/or `redis.enabled: false`
2. Configure connection details under `immich.database.*` or `immich.redis.*`

See [external-services.yaml](charts/immich/examples/external-services.yaml) for a complete example.

## Advanced Configuration

This chart is built on the [bjw-s common library](https://github.com/bjw-s-labs/helm-charts/tree/common-4.3.0/charts/library/common), which provides extensive Kubernetes configuration options:

- Pod annotations and labels
- Node affinity and tolerations
- Security contexts
- Init containers
- Sidecars
- And much more

For advanced configuration patterns, refer to the [common library documentation](https://github.com/bjw-s-labs/helm-charts/blob/common-4.3.0/charts/library/common/values.yaml).

### Chart Architecture

The chart deploys two main controllers:

- **server** - Main Immich API and web interface
- **machine-learning** - ML service for face detection, object recognition, etc. (automatically disabled when `immich.machineLearning.enabled: false`)

Configuration uses semantic objects (`immich.database`, `immich.redis`, etc.) that are automatically transformed into appropriate environment variables for all components.

## Accessing Immich

After installation, access Immich using one of these methods:

**Port Forward** (for testing):
```bash
kubectl port-forward -n immich svc/immich-server 2283:2283
# Access at http://localhost:2283
```

**LoadBalancer Service** (for production without ingress):
```yaml
service:
  server:
    type: LoadBalancer
```

**Ingress** (for production with domain):
```yaml
ingress:
  server:
    enabled: true
    hosts:
      - host: immich.yourdomain.com
        paths:
          - path: /
```

## Uninstalling

View installed releases:
```bash
helm ls --namespace immich
```

Uninstall the chart:
```bash
helm delete --namespace immich immich
```

This removes all Kubernetes resources associated with the release. Persistent volumes may need to be manually deleted depending on your storage class retention policy.
