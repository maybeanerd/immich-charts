# Upgrade Guide

This document provides migration guides for upgrading between versions of the Immich Helm chart.

**Note:** This chart follows [Semantic Versioning](https://semver.org/). While in major version zero (0.x.x), minor version increments (0.x.0) may include breaking changes as per the [SemVer specification](https://semver.org/#spec-item-4): "Major version zero (0.y.z) is for initial development. Anything MAY change at any time."

## Quick Reference

For the most current documentation and default values, refer to:
- [values.yaml](charts/immich/values.yaml) - Complete default values with inline documentation
- [Configuration Examples](charts/immich/examples/) - Working examples for common scenarios
- [README.md](README.md) - General configuration guide

The detailed migration guide below will help ensure you don't miss any changes when upgrading from specific versions.

---

## Version 0.11.0

### Overview

Version 0.11.0 introduces significant restructuring of the values schema to provide a cleaner, more intuitive configuration interface. The chart now manages internal complexity automatically while exposing only user-relevant settings at the top level.


### Breaking Changes

#### 1. New Top-Level Configuration Structure

The chart introduces a new `immich` section that consolidates all Immich-specific settings:

**Old structure:**
```yaml
controllers:
  server:
    enabled: true
    # ... complex controller configuration
  machine-learning:
    enabled: true
    # ... complex controller configuration
```

**New structure:**
```yaml
immich:
  machineLearning:
    enabled: true
  
  database:
    storageType: hdd
  
  monitoring:
    enabled: false
  
  redis: {}
```

**Action required:** Remove custom `controllers` configuration. The chart now manages controllers internally. If you need to customize controllers, use the common library's advanced features.

#### 2. Machine Learning Control

Machine Learning is now controlled via a top-level setting instead of controller configuration.

**Migration:**
```yaml
# OLD (no longer supported)
controllers:
  machine-learning:
    enabled: false

# NEW
immich:
  machineLearning:
    enabled: false
```

#### 3. Persistence Configuration Changes

**Storage sizes have changed:**

| Volume | Old Default | New Default | Notes |
|--------|-------------|-------------|-------|
| `library` | 10Gi | **100Gi** | Increased for typical photo collections |
| `external` | 10Gi | **10Gi** | No change |
| `machine-learning-cache` | 10Gi | **10Gi** | No change |
| PostgreSQL | 100Gi | **20Gi** | Reduced, as database is typically smaller |

**Access mode has changed:**

| Volume | Old Default | New Default | Notes |
|--------|-------------|-------------|-------|
| All volumes | `ReadWriteMany` | **`ReadWriteOnce`** | Better compatibility with most storage providers |

**Action required:** Review your storage requirements and explicitly set sizes if needed:
```yaml
persistence:
  library:
    size: 100Gi  # Now the default, but you may need more
    accessMode: ReadWriteOnce  # Or ReadWriteMany if required
  
postgresql:
  primary:
    persistence:
      size: 20Gi  # Adjust based on your database size
```

#### 4. PostgreSQL Configuration Restructure

**Password Configuration:**

The PostgreSQL password is now set at `postgresql.auth.password` instead of `postgresql.global.postgresql.auth.password`.

**Migration:**
```yaml
# OLD
postgresql:
  global:
    postgresql:
      auth:
        password: "your-password"

# NEW
postgresql:
  auth:
    password: "your-password"  # Or use existingSecret
    # existingSecret: immich-postgresql-secret
```

**Environment Variables:**

PostgreSQL environment variables are now managed via a ConfigMap.

**Migration:**
```yaml
# OLD
postgresql:
  primary:
    extraEnvVars:
      - name: DB_STORAGE_TYPE
        value: 'HDD'
      - name: POSTGRES_DB
        value: immich

# NEW
immich:
  database:
    storageType: hdd  # Controls DB_STORAGE_TYPE automatically

```

**Action required:** 
- Move your password to `postgresql.auth.password`
- Set database storage type at `immich.database.storageType` (options: `hdd` or `ssd`)
- Remove custom `extraEnvVars` that are now managed automatically

#### 5. External Database/Redis Configuration

External database and Redis configuration is now centralized under the `immich` section.

**Migration:**
```yaml
# NEW: External database configuration
immich:
  database:
    host: "postgres.example.com"
    port: 5432
    username: "immich"
    name: "immich"
    password: "your-password"
    # Or use secret reference:
    # password:
    #   valueFrom:
    #     secretKeyRef:
    #       name: immich-db-secret
    #       key: password

# NEW: External Redis configuration
immich:
  redis:
    host: "redis.example.com"
    port: 6379

# Don't forget to disable bundled services:
postgresql:
  enabled: false

redis:
  enabled: false
```


### Typically Non-Breaking Changes

#### 1. PostgreSQL Superuser Disabled

The PostgreSQL superuser (`postgres`) is now disabled by default to prevent ArgoCD drift. All operations run as the `immich` user, which has sufficient privileges.


### Migration Checklist

- [ ] Review persistence sizes and adjust if needed
- [ ] Review persistence access modes (change from `ReadWriteMany` to `ReadWriteOnce` or vice versa)
- [ ] Move PostgreSQL password to `postgresql.auth.password`
- [ ] Move database storage type to `immich.database.storageType`
- [ ] Remove custom `controllers` configuration
- [ ] Update Machine Learning enable/disable to use `immich.machineLearning.enabled`
- [ ] If using external database/Redis, migrate configuration to `immich.database` / `immich.redis`


### Example Migration

**Before (0.10.x):**
```yaml
immich:
  configuration: {}

controllers:
  machine-learning:
    enabled: false

persistence:
  library:
    accessMode: ReadWriteMany

postgresql:
  enabled: true
  global:
    postgresql:
      auth:
        password: "my-secret-password"
  primary:
    extraEnvVars:
      - name: DB_STORAGE_TYPE
        value: 'SSD'
    persistence:
      size: 100Gi
```

**After (0.11.x):**
```yaml
# image.tag is now managed internally, no need to set

immich:
  configuration: {}
  
  machineLearning:
    enabled: false
  
  database:
    storageType: ssd

persistence:
  library:
    size: 10Gi  # To ensure the old default value is still applied
    accessMode: ReadWriteMany # To ensure your volumes access doesn't change

postgresql:
  enabled: true
  auth:
    password: "my-secret-password"
  primary:
    persistence:
      size: 100Gi  # To ensure the old default value is still applied
```

---

## Need Help?

If you encounter issues during migration, open an issue on [GitHub](https://github.com/maybeanerd/immich-charts/issues).

