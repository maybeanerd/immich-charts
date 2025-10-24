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

Before deploying Immich, you **must** configure these values:

1. **Storage Classes** - All persistent volumes need a `storageClass`:
   - `persistence.library.storageClass` - User library (photos/videos)
   - `persistence.external.storageClass` - External libraries
   - `persistence.machine-learning-cache.storageClass` - ML cache (if ML enabled)
   - `postgresql.primary.persistence.storageClass` - Database (if using bundled PostgreSQL)

2. **Database Password** - Set a secure password:
   - `immich.database.password` - Required for bundled PostgreSQL
   - Or use `immich.database.password.valueFrom.secretKeyRef` for existing secrets

### What You Might Want to Configure

Common customizations based on your deployment needs:

#### Basic Configuration
- **Ingress** - Enable and configure hostname for web access (`ingress.server`)
- **Storage Sizes** - Adjust volume sizes based on your needs (`persistence.*.size`)
- **Database Storage Type** - Optimize for SSD storage (`immich.database.storageType: ssd`)

#### Resource Management
- **Machine Learning** - Disable to save resources (`immich.machineLearning.enabled: false`)
- **Resource Limits** - Set CPU/memory for workloads (`controllers.*.resources`)
- **Replicas** - Scale the server component (`controllers.server.replicas`)

#### External Services
- **External Database** - Use managed PostgreSQL (`postgresql.enabled: false`, configure `immich.database.*`)
- **External Redis** - Use managed Redis (`redis.enabled: false`, configure `immich.redis.*`)

#### Advanced Features
- **Application Configuration** - Manage Immich settings via config file (`immich.configuration`)
- **Monitoring** - Enable Prometheus metrics (`immich.monitoring.enabled`)
- **GPU Acceleration** - Add GPU resources for ML (`controllers.machine-learning.resources.limits`)

### Configuration Examples

We provide tested examples for common deployment scenarios:

- **[minimal.yaml](charts/immich/examples/minimal.yaml)** - Basic setup with bundled PostgreSQL and Redis
- **[ssd-optimized.yaml](charts/immich/examples/ssd-optimized.yaml)** - PostgreSQL optimized for SSD storage
- **[external-services.yaml](charts/immich/examples/external-services.yaml)** - Using external PostgreSQL and Redis
- **[ml-disabled.yaml](charts/immich/examples/ml-disabled.yaml)** - Deployment without machine learning features
- **[custom-config.yaml](charts/immich/examples/custom-config.yaml)** - Custom Immich application configuration

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
