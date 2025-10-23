# Immich Helm Chart Examples

This directory contains example configurations for common deployment scenarios. All examples are tested in CI/CD to ensure they work correctly.

## Available Examples

### [minimal.yaml](./minimal.yaml)
The bare minimum configuration needed to deploy Immich. Good starting point for new deployments.

**Use case**: Quick setup, development, testing, basic production deployments

**Features**:
- Bundled PostgreSQL and Redis
- Machine learning enabled
- Ingress enabled (default)
- Basic storage configuration

**Deploy with**:
```bash
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/minimal.yaml
```

### [external-services.yaml](./external-services.yaml)
Configuration for using external PostgreSQL and Redis instead of bundled services.

**Use case**: Production deployments with managed database services, database/Redis sharing between applications

**Features**:
- External PostgreSQL connection with secret-based password
- External Redis connection
- No bundled dependencies
- Larger storage allocations for production

**Deploy with**:
```bash
# First, create your database secret:
kubectl create secret generic immich-db-secret \
  --from-literal=password=your-secure-password \
  --namespace immich

helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/external-services.yaml
```

### [ml-disabled.yaml](./ml-disabled.yaml)
Configuration with machine learning features disabled to save resources.

**Use case**: Resource-constrained environments, deployments not requiring ML features

**Features**:
- ML service disabled (no face detection, object recognition, or smart search)
- Reduced resource requirements
- Automatic cleanup of ML-related resources

**Deploy with**:
```bash
helm install immich oci://ghcr.io/maybeanerd/immich-charts/immich \
  --namespace immich --create-namespace \
  -f https://raw.githubusercontent.com/maybeanerd/immich-charts/main/charts/immich/examples/ml-disabled.yaml
```

## Customization

These examples are starting points. Before deploying to production, you should:

1. **⚠️ Change passwords**: Never use default or example passwords
2. **Update storage classes**: Use storage classes available in your cluster
3. **Adjust sizes**: Size storage based on your expected usage
4. **Update hostnames**: Replace `immich.local` and `example.com` with your actual domain
5. **Configure ingress**: Set up TLS certificates and appropriate ingress annotations
6. **Review resources**: Adjust CPU/memory based on your workload

## Testing Locally

You can test any example locally without deploying:

```bash
# Render the manifests
helm template immich charts/immich -f charts/immich/examples/minimal.yaml

# Validate the chart
helm lint charts/immich -f charts/immich/examples/minimal.yaml
```

## CI/CD

All examples are automatically tested in our CI/CD pipeline on every pull request. The workflow:
1. Validates each example can be rendered successfully
2. Generates manifest diffs against the main branch
3. Posts diff comments for each example on the PR

This ensures examples stay up-to-date and functional with chart changes.
