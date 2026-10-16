#!/usr/bin/env bash
# Regenerates Sources/<Module>/Generated and the oracle corpus samples from the upstream IDL
# pinned in idl.lock, with the swift-ros2-gen of the rosidl version in Package.resolved.
set -euo pipefail
cd "$(dirname "$0")/.."
bash Scripts/fetch-idl.sh
ARGS=()
while IFS= read -r line; do ARGS+=("$line"); done < <(bash Scripts/generator-args.sh)
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
# swift-ros2-gen is a dependency's executable product: `swift run` builds and runs it
# (`swift build --product` only takes this package's own products).
swift run -c release swift-ros2-gen "${ARGS[@]}" --output "$OUT/types" --emit-oracle-samples "$OUT/samples"
for dir in "$OUT"/types/*/; do
  module=$(basename "$dir")
  rm -rf "Sources/$module/Generated"
  mkdir -p "Sources/$module/Generated"
  cp "$dir"*.swift "Sources/$module/Generated/"
done
rm -rf Sources/ExtraInterfacesOracleCorpus/Generated
mkdir -p Sources/ExtraInterfacesOracleCorpus/Generated
cp "$OUT"/samples/*.swift Sources/ExtraInterfacesOracleCorpus/Generated/
echo "regenerated: $(ls "$OUT"/types | tr '\n' ' ')"
