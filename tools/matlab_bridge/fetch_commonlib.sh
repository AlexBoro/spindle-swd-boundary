#!/usr/bin/env bash
# Fetch the commonlib helper functions that detectEEGspikesSWDs.m needs but the
# Zenodo deposit omits. They are NOT vendored here: dervinism/commonlib carries
# no licence file, so redistribution is not clearly permitted. See
# docs/matlab_dependencies.md.
set -euo pipefail

SHA="deb441aad510113458c604363e6465e628825f14"
DEST="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$DEST"
git clone -q --depth 1 https://github.com/dervinism/commonlib.git "$TMP/commonlib"
git -C "$TMP/commonlib" fetch -q --depth 1 origin "$SHA" 2>/dev/null || true
git -C "$TMP/commonlib" checkout -q "$SHA" 2>/dev/null \
  || echo "warning: pinned commit $SHA unavailable; using current HEAD ($(git -C "$TMP/commonlib" rev-parse --short HEAD))"

for f in designFilterBP.m hilbertTransform.m recentrePhase.m; do
    cp "$TMP/commonlib/$f" "$DEST/$f"
    echo "fetched $f"
done
echo "done -> $DEST"
