# Disclaimer

This is a soft fork from the [official immich-charts](https://github.com/immich-app/immich-charts) repo. The aim is to provide a better developer experience, more granular releases (including all immich versions), and a more comprehensive chart (including DB, e.g.)

It was created based on the discussions in the following issue: https://github.com/immich-app/immich-charts/issues/68#issuecomment-2291250875

THIS IS A WIP.

Do not use this in production. It's a true [zero-ver](https://semver.org/#spec-item-4), which means every other release might include breaking changes. We have just started, and need to first adjust the chart to the expectations we have, before we can provide the value it's supposed to provide.

Feel free to play around with it. Please try and test it. But don't expect it to work as a replacement of the old chart quite yet.

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

This Helm chart for Immich is highly configurable. Below are the most important values you may want or need to change for your deployment.  
**See `charts/immich/values.yaml` for the full list of options.**

| Parameter                                                   | Description                                                                                                                                       | Default                                                                                 |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `immich.configuration`                                      | Immich app configuration (see [docs](https://immich.app/docs/install/config-file/))                                                               | `{}`                                                                                    |
| `controllers.server.containers.main.env.IMMICH_CONFIG_FILE` | Path to the immich config file. If you don't want to use the config file, and instead configure immich using the GUI, set this to `null`. service | `/config/immich-config.yaml`                                                            |
| `controllers.machine-learning.enabled`                      | Enable machine learning service                                                                                                                   | `true`                                                                                  |
| `persistence.library.existingClaim`                         | If you dont want this chart to create a PVC for you, e.g. because you already have one, you can pass the name of your existing claim instead.     | `null`                                                                                  |
| `persistence.library.storageClass`                          | Storage class for user library                                                                                                                    | `null` (must be set, unless you use an existing claim)                                  |
| `persistence.library.size`                                  | Size of the user library volume                                                                                                                   | `10Gi`                                                                                  |
| `persistence.external.enabled`                              | If a persistent volume should be used for external libraries                                                                                      | `true`                                                                                  |
| `persistence.external.existingClaim`                        | If you dont want this chart to create a PVC for you, e.g. because you already have one, you can pass the name of your existing claim instead.     | `null`                                                                                  |
| `persistence.external.storageClass`                         | Storage class for external volume                                                                                                                 | `null` (must be set, unless you use an existing claim)                                  |
| `persistence.external.size`                                 | Size of the external volume                                                                                                                       | `10Gi`                                                                                  |
| `persistence.machine-learning-cache.existingClaim`          | If you dont want this chart to create a PVC for you, e.g. because you already have one, you can pass the name of your existing claim instead.     | `null`                                                                                  |
| `persistence.machine-learning-cache.storageClass`           | Storage class for external volume                                                                                                                 | `null` (must be set, unless you use an existing claim)                                  |
| `persistence.machine-learning-cache.type`                   | Type for ML cache volume                                                                                                                          | `persistentVolumeClaim` (set to `emptyDir` to not persist ML models)                    |
| `ingress.server.enabled`                                    | Enable ingress for Immich server                                                                                                                  | `false`                                                                                 |
| `ingress.server.hosts`                                      | Ingress hosts                                                                                                                                     | `immich.local`                                                                          |
| `postgresql.enabled`                                        | Deploy bundled PostgreSQL                                                                                                                         | `true`                                                                                  |
| `postgresql.global.postgresql.auth.password`                | PostgreSQL password (should be a long, generated, random string)                                                                                  | `null` (must be set, unless you use an existing secret)                                 |
| `postgresql.global.postgresql.auth.existingSecret`          | PostgreSQL password from a kubernetes secret. Set as alternative to passing the password above.                                                   | `null`                                                                                  |
| `postgresql.primary.persistence.size`                       | PostgreSQL volume size                                                                                                                            | `100Gi`                                                                                 |
| `postgresql.primary.persistence.existingClaim`              | If you dont want this chart to create a PVC for you, e.g. because you already have one, you can pass the name of your existing claim instead.     | `null`                                                                                  |
| `postgresql.primary.persistence.storageClass`               | PostgreSQL storage class                                                                                                                          | `null` (must be set, unless you use an existing claim)                                  |
| `postgresql.primary.resources`                              | PostgreSQL resource requests/limits                                                                                                               | `{ requests: { memory: "512Mi", limits: memory: "2Gi"} }` (see values.yaml for example) |
| `redis.enabled`                                             | Deploy bundled Redis                                                                                                                              | `true`                                                                                  |

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

## Chart architecture 

This chart uses the [common library](https://github.com/bjw-s-labs/helm-charts/tree/common-4.3.0/charts/library/common). 

You can freely add more top level keys to be applied to all the components, please reference [the common library's values.yaml](https://github.com/bjw-s-labs/helm-charts/blob/common-4.3.0/charts/library/common/values.yaml) to see what keys are available.

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
