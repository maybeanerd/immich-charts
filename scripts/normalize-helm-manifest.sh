#!/usr/bin/env bash
set -euo pipefail

# 1. Use awk to replace newlines within a document with a special marker ( \x01 )
# 2. This turns each YAML document into one "giant line"
# 3. Sort these giant lines alphabetically
# 4. Swap the marker back for newlines
awk '
  BEGIN { RS = "---\n"; ORS = "" }
  {
    gsub(/\n/, "\x01", $0)
    print $0 "\n"
  }
' | sort | awk '
  BEGIN { ORS = "" }
  {
    gsub(/\x01/, "\n", $0)
    print "---\n" $0
  }
'