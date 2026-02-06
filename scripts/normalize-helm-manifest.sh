#!/usr/bin/env bash
# Normalize a multi-document YAML manifest so documents are in a stable order.
# Splits on ---, sorts documents alphabetically (by content), rejoins.
# Use before diffing to avoid spurious diffs from helm template output order.
#
# Usage:
#   ./normalize-helm-manifest.sh < input.yaml > normalized.yaml
#   ./normalize-helm-manifest.sh input.yaml > normalized.yaml
#   helm template ... | ./normalize-helm-manifest.sh > manifest.yaml

set -euo pipefail

# Use Python for reliable multi-line sort (available on GitHub Actions runners)
# Usage: script [input.yaml]  (default: stdin)
exec python3 - "$@" <<'PY'
import sys

def main():
    if len(sys.argv) > 1 and sys.argv[1] != "-":
        with open(sys.argv[1]) as f:
            data = f.read()
    else:
        data = sys.stdin.read()
    docs = [d.strip() for d in data.split("\n---") if d.strip()]
    docs.sort()
    sys.stdout.write("\n---\n".join(docs))
    if docs:
        sys.stdout.write("\n")

if __name__ == "__main__":
    main()
PY
