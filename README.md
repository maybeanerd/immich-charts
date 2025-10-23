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

This Helm chart for Immich is highly configurable. The chart uses a clean values structure where defaults are provided in templates, and users only need to override what they want to change.

**See `charts/immich/values.yaml` for the full list of options and examples.**

## Quick Start

### Example Configurations

We provide tested example configurations for common scenarios. See the [examples directory](charts/immich/examples/) for more details.

**Minimal setup** (bundled database and Redis):
```bash
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/minimal.yaml
```

**With external services** (managed PostgreSQL and Redis):
```bash
kubectl create secret generic immich-db-secret --from-literal=password=your-secure-password
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/external-services.yaml
```

**Without machine learning** (saves resources):
```bash
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/ml-disabled.yaml
```

⚠️ **Important**: These examples use placeholder values. Before deploying to production:
- Change `CHANGE-ME-TO-A-SECURE-PASSWORD` to a secure password
- Update `storageClass` to match your cluster's storage provisioners
- Adjust storage sizes based on your needs
- Update ingress hostnames from `immich.local` to your domain

## Configuration Reference

### Immich Configuration

| Parameter                       | Description                                                                      | Default  |
| ------------------------------- | -------------------------------------------------------------------------------- | -------- |
| `prometheus.enabled`            | Enable Prometheus metrics endpoints and ServiceMonitor                           | `false`  |
| `immich.configuration`          | Immich app configuration (see [docs](https://immich.app/docs/install/config-file/)) | `{}` |
| `immich.database`               | Database connection configuration (see below)                                    | `{}` |
| `immich.redis`                  | Redis connection configuration (see below)                                       | `{}` |
| `immich.machineLearning.enabled`| Enable or disable ML features (face detection, object recognition, etc.)         | `true`   |

> **Note**: The image version is managed by the chart and should not be overridden by users.

#### Prometheus Monitoring

Enable Prometheus metrics collection:

```yaml
prometheus:
  enabled: true  # Enables metrics endpoints and creates ServiceMonitor
```

When enabled, this will:
- Expose metrics on ports 8081 (API metrics) and 8082 (Microservices metrics)
- Create a ServiceMonitor resource for Prometheus Operator
- Allow monitoring of Immich performance and health

#### Database Configuration (`immich.database`)

Configure the database connection. If not specified, defaults to the bundled PostgreSQL instance.

> **Note**: When using an external database, set `postgresql.enabled: false` to disable the bundled PostgreSQL.

```yaml
immich:
  database:
    host: "postgres.example.com"
    port: 5432  # optional, defaults to 5432
    username: "immich"
    name: "immich"
    password: "password"
    
    # Or use a Kubernetes secret for the password:
    password:
      valueFrom:
        secretKeyRef:
          name: immich-db-secret
          key: password
```

#### Redis Configuration (`immich.redis`)

Configure the Redis connection. If not specified, defaults to the bundled Redis instance.

> **Note**: When using external Redis, set `redis.enabled: false` to disable the bundled Redis.

```yaml
immich:
  redis:
    host: "redis.example.com"
    port: 6379  # optional, defaults to 6379
```

#### Machine Learning Configuration (`immich.machineLearning`)

Enable or disable the machine learning service. When disabled, saves resources but removes features like face detection and object recognition:

```yaml
immich:
  machineLearning:
    enabled: false  # Set to false to disable ML features
```

The ML service URL is automatically configured to use the internal service and cannot be overridden. This section can be extended in the future with additional ML-related settings.

### Persistence

| Parameter                                  | Description                                    | Default                |
| ------------------------------------------ | ---------------------------------------------- | ---------------------- |
| `persistence.library.storageClass`         | Storage class for user library                 | `null` (must be set)   |
| `persistence.library.size`                 | Size of the user library volume                | `10Gi`                 |
| `persistence.library.existingClaim`        | Use an existing PVC instead of creating one    | `null`                 |
| `persistence.external.storageClass`        | Storage class for external libraries           | `null` (must be set)   |
| `persistence.external.size`                | Size of the external volume                    | `10Gi`                 |
| `persistence.external.existingClaim`       | Use an existing PVC instead of creating one    | `null`                 |
| `persistence.machine-learning-cache.type`  | Type for ML cache (`persistentVolumeClaim` or `emptyDir`) | `persistentVolumeClaim` |
| `persistence.machine-learning-cache.storageClass` | Storage class for ML cache          | `null` (must be set)   |
| `persistence.machine-learning-cache.size`  | Size of the ML cache volume                    | `10Gi`                 |

### Controllers

Override controller settings for server and machine-learning:

```yaml
# Enable or disable machine learning
immich:
  machineLearning:
    enabled: true  # Set to false to disable ML features

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
    replicas: 1
    containers:
      main:
        resources:
          limits:
            nvidia.com/gpu: 1  # For GPU acceleration
```

### Ingress

| Parameter                      | Description                    | Default  |
| ------------------------------ | ------------------------------ | -------- |
| `ingress.server.enabled`       | Enable ingress for Immich      | `true`   |
| `ingress.server.hosts`         | Ingress hosts configuration    | `immich.local` |
| `ingress.server.annotations`   | Ingress annotations            | `proxy-body-size: 0` |
| `ingress.server.tls`           | Ingress TLS configuration      | `[]`     |

### Database (PostgreSQL)

Default configuration is managed in `templates/postgresql.yaml`. You can override settings in `values.yaml`:

```yaml
postgresql:
  primary:
    persistence:
      size: 200Gi
      storageClass: fast-ssd
    resources:
      limits:
        memory: 4Gi
```

Key settings:
- Default size: `100Gi`
- Vector extensions pre-installed (cube, earthdistance, vectors)
- Optimized for Immich workload

### Redis

Default configuration is managed in `templates/redis.yaml`. You can override settings in `values.yaml`:

```yaml
redis:
  master:
    persistence:
      enabled: true
      size: 1Gi
```

Key settings:
- Standalone architecture
- Persistence disabled by default
- Auth disabled for simplicity

### Required Changes

- **Database password:**  
  You must set a secure password for PostgreSQL, ideally using Kubernetes secrets.  
  Set `postgresql.global.postgresql.auth.password` or use `postgresql.global.postgresql.auth.existingSecret` if possible.

- **Storage classes:**  
  Set `persistence.library.storageClass`, `persistence.external.storageClass`, `persistence.machine-learning-cache.storageClass`,and `postgresql.primary.persistence.storageClass` to match your cluster’s storage provisioner.

  Alernatively, create the required PVCs yourself and set `existingClaim` for each volume to use them.

### Useful Changes

- **Ingress:**  
  Set `ingress.server.enabled: true` and configure `ingress.server.hosts` and TLS as needed.

- **Resource requests/limits:**  
  Adjust `postgresql.primary.resources` and other resource settings to fit your environment.


---

**Note:**  
This table is not exhaustive. See `charts/immich/values.yaml` for all options and further documentation links.

## Advanced Configuration

### Using Common Chart Features

This chart uses the [common library](https://github.com/bjw-s-labs/helm-charts/tree/common-4.3.0/charts/library/common), which provides many advanced Kubernetes features.

You can apply common chart features to specific controllers. Here are some examples:

#### Node Affinity

Pin services to specific nodes:

```yaml
controllers:
  server:
    pod:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: workload-type
                    operator: In
                    values:
                      - web
  
  machine-learning:
    pod:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: gpu
                    operator: In
                    values:
                      - nvidia
```

#### Tolerations

Allow pods to run on tainted nodes:

```yaml
controllers:
  server:
    pod:
      tolerations:
        - key: "dedicated"
          operator: "Equal"
          value: "immich"
          effect: "NoSchedule"
```

#### Pod Security Context

Set security contexts:

```yaml
controllers:
  server:
    pod:
      securityContext:
        runAsUser: 1000
        runAsGroup: 1000
        fsGroup: 1000
```

#### Init Containers

Add init containers for setup tasks:

```yaml
controllers:
  server:
    initContainers:
      init-permissions:
        image:
          repository: busybox
          tag: latest
        command:
          - sh
          - -c
          - chown -R 1000:1000 /data
```

#### Service Annotations

Add annotations to services (e.g., for load balancer configuration):

```yaml
service:
  server:
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
```

### External Database

To use an external PostgreSQL database:

```yaml
# Disable bundled PostgreSQL
postgresql:
  enabled: false

# Configure external database connection
immich:
  database:
    host: "postgres.example.com"
    port: 5432
    username: "immich"
    name: "immich"
    password:
      valueFrom:
        secretKeyRef:
          name: immich-db-secret
          key: password
```

### External Redis

To use an external Redis instance:

```yaml
# Disable bundled Redis
redis:
  enabled: false

# Configure external Redis connection
immich:
  redis:
    host: "redis.example.com"
    port: 6379
```

### Monitoring

Enable Prometheus metrics collection:

```yaml
prometheus:
  enabled: true
```

This automatically:
- Enables metrics endpoints (ports 8081 and 8082)
- Creates a ServiceMonitor resource for Prometheus Operator
- Exposes API and microservices metrics for monitoring

### High Availability

Run multiple replicas with proper anti-affinity:

```yaml
controllers:
  server:
    replicas: 3
    pod:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app.kubernetes.io/controller
                      operator: In
                      values:
                        - server
                topologyKey: kubernetes.io/hostname
```

## Chart Architecture 

This chart uses the [common library](https://github.com/bjw-s-labs/helm-charts/tree/common-4.3.0/charts/library/common). 

The chart defines two main controllers:
- **server**: The main Immich API and web interface
- **machine-learning**: The machine learning service for face detection, object recognition, etc.

### Configuration Design

The chart uses semantic configuration objects rather than exposing raw environment variables:

- **`immich.database`**: Database connection settings (host, port, username, name, password)
- **`immich.redis`**: Redis connection settings (host, port)
- **`immich.machineLearning.enabled`**: Enable/disable the ML service

These high-level configurations are automatically transformed into the appropriate environment variables for all Immich components. This approach provides:

1. **Clear intent**: Configuration objects are self-documenting
2. **Type safety**: Proper structure for complex values (like secrets)
3. **Smart defaults**: Automatically uses bundled services when not specified
4. **Consistency**: Same configuration applied to all components
5. **Extensibility**: Configuration sections can be enriched with additional settings as needed

The machine learning service URL is automatically configured and cannot be overridden as it always uses the internal service.

For more advanced configurations, please reference [the common library's values.yaml](https://github.com/bjw-s-labs/helm-charts/blob/common-4.3.0/charts/library/common/values.yaml) to see all available options.

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
