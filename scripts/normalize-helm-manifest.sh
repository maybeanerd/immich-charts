#!/usr/bin/env bash
set -euo pipefail

# Install yq if it's missing (common in Alpine)
if ! command -v yq &> /dev/null; then
    apk add --no-cache yq
fi

# Sort all YAML documents in the stream by Kind and Name
yq eval-all '. | sort_by(.kind + .metadata.name) | split_doc' -