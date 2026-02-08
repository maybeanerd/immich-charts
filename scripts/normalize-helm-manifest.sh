#!/usr/bin/env bash
set -euo pipefail

# Ensure yq is installed
if ! command -v yq &> /dev/null; then
    apk add --no-cache yq
fi

# 1. eval-all: Loads all documents into memory
# 2. select(.) : Removes null/empty documents
# 3. sort_by(...) : Orders them by Kind and Name for a stable diff
# 4. split_doc : Outputs them back as separate --- documents
yq eval-all '
  select(.) | 
  sort_by(.kind + .metadata.name) | 
  split_doc
' -