#!/usr/bin/env bash
# Fails when .github/workflows/oracles.yml calls the rosidl oracle workflow at a version other
# than the swift-ros2-rosidl version Package.resolved pins. The two move together.
set -euo pipefail
cd "$(dirname "$0")/.."

resolved=$(grep -A6 '"identity" : "swift-ros2-rosidl"' Package.resolved \
    | sed -n 's/.*"version" : "\(.*\)".*/\1/p')
ref=$(sed -n 's|.*swift-ros2-rosidl/.github/workflows/interface-oracles.yml@\([^[:space:]]*\).*|\1|p' \
    .github/workflows/oracles.yml)

if [[ -z "$resolved" || -z "$ref" ]]; then
    echo "error: could not read the rosidl version (Package.resolved: '$resolved', oracles.yml: '$ref')" >&2
    exit 1
fi
if [[ "$resolved" != "$ref" ]]; then
    echo "error: oracles.yml uses interface-oracles.yml@$ref but Package.resolved pins rosidl $resolved" >&2
    exit 1
fi
echo "OK: oracles.yml and Package.resolved both use rosidl $resolved"
