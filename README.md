# Disclaimer

This is a fork from the [official immich-charts](https://github.com/immich-app/immich-charts) repo. The aim is to provide a better developer experience, more granular releases (including all immich versions), and a more comprehensive chart (including database, e.g.)

It was created based on the discussions in the following issue: https://github.com/immich-app/immich-charts/issues/68#issuecomment-2291250875

THIS IS A WIP.

Do not use this in production. It's a true [zero-ver](https://semver.org/#spec-item-4), which means every other release might include breaking changes.

Feel free to play around with it. Please try and test it. Breaking changes will be marked in release notes, so please keep an eye out for them when updating version.

# Immich Charts

Installs [Immich](https://github.com/immich-app/immich), a self-hosted photo and video backup solution directly 
from your mobile phone. 

# Goal

This repo contains helm charts the immich community developed to help deploy Immich on Kubernetes cluster.

It leverages the bjw-s [common-library chart](https://github.com/bjw-s-labs/helm-charts/tree/common-4.3.0/charts/library/common) to make configuration as easy as possible. 

# Installation

```
$ helm install --create-namespace --namespace immich immich oci://ghcr.io/maybeanerd/immich-charts/immich -f values.yaml
```

You should not copy the full values.yaml from this repository. Only set the values that you want to override.

# Configuration

TODO: rework this, and streamline it

This Helm chart for Immich is highly configurable. The chart uses a clean values structure where defaults are provided in templates, and users only need to override what they want to change.

## Quick Start

We provide tested example configurations for common scenarios. See the [examples directory](charts/immich/examples/) for detailed documentation:

- **[minimal.yaml](charts/immich/examples/minimal.yaml)** - Bare minimum setup with bundled services
- **[external-services.yaml](charts/immich/examples/external-services.yaml)** - Using external PostgreSQL and Redis
- **[ml-disabled.yaml](charts/immich/examples/ml-disabled.yaml)** - Deployment without machine learning features

Deploy an example:
```bash
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/minimal.yaml
```

⚠️ **Important**: Examples use placeholder values. Before production deployment, update passwords, storage classes, sizes, and hostnames.

## Configuration Reference

### Required Values

These values **must** be configured before deployment:

#### Storage Classes
All persistent volumes require a `storageClass` matching your cluster's provisioner:

```yaml
persistence:
  library:
    storageClass: "your-storage-class"  # User library (photos/videos)
  external:
    storageClass: "your-storage-class"  # External libraries
  machine-learning-cache:
    storageClass: "your-storage-class"  # ML cache (only if ML enabled)

postgresql:
  primary:
    persistence:
      storageClass: "your-storage-class"  # Database
```

Alternatively, use existing PVCs with `existingClaim`.

#### Database Password
Set a secure password for bundled PostgreSQL (when `postgresql.enabled: true`):

```yaml
postgresql:
  enabled: true
  global:
    postgresql:
      auth:
        password: "your-secure-password"
        # Better: use existingSecret for production
```

### Interesting Values to Change

#### Immich Application Settings (`immich`)

```yaml
immich:
  # Application configuration - see https://immich.app/docs/install/config-file/
  # Set to {} for defaults, null for GUI management, or provide values for GitOps
  configuration: {}
  
  # Example GitOps configuration:
  # configuration:
  #   trash:
  #     enabled: false
  #     days: 30
  #   storageTemplate:
  #     enabled: true
  #     template: "{{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}"

  # Enable/disable machine learning features
  machineLearning:
    enabled: true  # Set false to save resources

  # Enable Prometheus metrics
  monitoring:
    enabled: false

  # Database configuration
  database:
    # External database (requires postgresql.enabled: false)
    # host: "postgres.example.com"
    # username: "immich"
    # name: "immich"
    # password:
    #   valueFrom:
    #     secretKeyRef:
    #       name: immich-db-secret
    #       key: password

  # Redis configuration
  # For external Redis, set redis.enabled: false
  # redis:
  #   host: "redis.example.com"
```

**Configuration Management Options:**

The `immich.configuration` field determines how Immich settings are managed:

- **Set to `{}` (default, recommended for GitOps)**: An empty config file is created and merged with Immich's internal defaults. This is the recommended approach for declarative deployments as configuration is version-controlled and predictable.
- **Set to `null`**: No config file is mounted. Configuration is managed entirely through the Immich web GUI, with settings persisted to the database. Use this if you prefer GUI-based configuration management.
- **Set with values**: A config file with your specific settings is created. These values override Immich's internal defaults. Use this for GitOps workflows where you need to customize specific settings declaratively.

> **Note**: When using a config file (`{}` or with values), configuration is managed through the chart. GUI-based changes may be limited or ignored as the config file takes precedence.

#### Storage Sizes (`persistence`)

```yaml
persistence:
  library:
    size: 100Gi  # Your photos/videos
  external:
    size: 50Gi   # External libraries
  machine-learning-cache:
    size: 10Gi   # ML models cache
```

#### Ingress (`ingress`)

```yaml
ingress:
  server:
    enabled: true
    hosts:
      - host: immich.yourdomain.com
        paths:
          - path: '/'
    tls:
      - secretName: immich-tls
        hosts:
          - immich.yourdomain.com
```

#### Resource Limits (`controllers`)

```yaml
controllers:
  server:
    replicas: 2
    containers:
      main:
        resources:
          requests:
            memory: 1Gi
            cpu: 500m
          limits:
            memory: 4Gi
  
  machine-learning:
    containers:
      main:
        resources:
          limits:
            nvidia.com/gpu: 1  # GPU acceleration
```

#### PostgreSQL (`postgresql`)

```yaml
# Use bundled PostgreSQL
postgresql:
  enabled: true
  primary:
    persistence:
      size: 200Gi
      storageClass: fast-ssd
    resources:
      limits:
        memory: 4Gi

# Optimize for SSD storage
postgresql:
  primary:
    extraEnvVars:
      - name: DB_STORAGE_TYPE
        value: SSD
      - name: POSTGRES_DB
        value: immich
      - name: POSTGRESQL_STARTUP_TIMEOUT
        value: '256'

# Or use external PostgreSQL
postgresql:
  enabled: false

immich:
  database:
    host: "postgres.example.com"
    username: "immich"
    name: "immich"
    password:
      valueFrom:
        secretKeyRef:
          name: immich-db-secret
          key: password
```

#### Redis (`redis`)

```yaml
# Use bundled Redis
redis:
  enabled: true
  master:
    persistence:
      enabled: true
      size: 1Gi

# Or use external Redis
redis:
  enabled: false

immich:
  redis:
    host: "redis.example.com"
```

## Advanced Configuration

This chart uses the [bjw-s common library](https://github.com/bjw-s-labs/helm-charts/tree/common-4.3.0/charts/library/common), providing access to advanced Kubernetes features. You can extend the chart by configuring any values supported by the common library.

### Example: Pod Annotations and Node Affinity

Add custom annotations to all pods and configure node affinity:

```yaml
# Global pod annotations apply to all controllers
podAnnotations:
  backup.velero.io/backup-volumes: library,external,machine-learning-cache
  prometheus.io/scrape: "true"
  linkerd.io/inject: enabled

# Controller-specific configuration
controllers:
  server:
    pod:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: node-role.kubernetes.io/worker
                    operator: Exists
  
  machine-learning:
    pod:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: node-role.kubernetes.io/worker
                    operator: Exists
```

This demonstrates how the chart can be extended with standard Kubernetes configurations. Global settings like `podAnnotations` apply to all controllers, while controller-specific settings can be customized individually. The common library supports many more features including tolerations, security contexts, init containers, and more.

For comprehensive examples, see the [common library documentation](https://github.com/bjw-s-labs/helm-charts/blob/common-4.3.0/charts/library/common/values.yaml).

### Chart Architecture

The chart defines two main controllers:
- **server**: Main Immich API and web interface
- **machine-learning**: ML service (face detection, object recognition, etc.) - automatically disabled when `immich.machineLearning.enabled: false`

Configuration uses semantic objects (`immich.database`, `immich.redis`, etc.) that are automatically transformed into appropriate environment variables for all components.

## Uninstalling the Chart

To see the currently installed Immich chart:

```console
helm ls --namespace immich
```

To uninstall/delete the `immich` chart:

```console
helm delete --namespace immich immich
```

The command removes all the Kubernetes components associated with the chart and deletes the release.
