#!/usr/bin/env bash
set -euo pipefail

# This script normalizes Helm output by sorting resources by Kind and Name.
# It ensures that "Service/my-app" is always compared against "Service/my-app".

awk '
  BEGIN { 
    RS = "---\n"; 
    ORS = "" 
  }
  {
    # 1. Extract Kind
    kind = "Unknown"
    if (match($0, /kind:[[:space:]]+[A-Za-z0-9]+/)) {
        kind = substr($0, RSTART + 5, RLENGTH - 5)
        gsub(/[[:space:]]/, "", kind)
    }

    # 2. Extract Name
    name = "Unknown"
    if (match($0, /name:[[:space:]]+[A-Za-z0-9.-]+/)) {
        name = substr($0, RSTART + 5, RLENGTH - 5)
        gsub(/[[:space:]]/, "", name)
    }

    # 3. Create a sortable prefix: Kind:Name|||OriginalContent
    if (length($0) > 0 && $0 ~ /[a-zA-Z0-9]/) {
        print kind ":" name "|||" $0 "---END_BLOCK---"
    }
  }
' | sort -V | awk '
  BEGIN { 
    RS = "---END_BLOCK---"; 
    ORS = "" 
  }
  {
    # Remove the sort key prefix and restore the YAML separator
    sub(/^[^|]+\|\|\|/, "", $0)
    if (length($0) > 0) {
        print "---\n" $0
    }
  }
'
