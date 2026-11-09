#!/bin/sh
# package.sh <artoo-version> <target>: a release build for that Artoo release, as dist/<id>-<artoo-version>-<target>.zip,
# the name Artoo's Settings → Plugins looks for.
set -e
cd "$(dirname "$0")/.."
version=$1 target=$2
library=$(sh scripts/build.sh release "$version" "$target")
id=$(sed -n 's/^name = "\(.*\)"/\1/p' Cargo.toml | head -1)
mkdir -p dist
out=$PWD/dist/$id-$version-$target.zip
rm -f "$out"
cd "$(dirname "$library")"
if command -v zip >/dev/null; then
  zip -q "$out" "$(basename "$library")"
else
  7z a -bd "$out" "$(basename "$library")" >/dev/null
fi
echo "$out"
