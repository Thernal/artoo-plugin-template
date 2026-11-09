#!/bin/sh
# fetch-sdk.sh <artoo-version> [<target>]: downloads what a plugin is built against for that Artoo release into
# .artoo-sdk/, and the compiler it was built with. Prints the folder.
set -e
cd "$(dirname "$0")/.."
version=$1
target=${2:-$(rustc -vV | sed -n 's/^host: //p')}
name=artoo-sdk-$version-$target
if [ ! -f ".artoo-sdk/$name/sdk.txt" ]; then
  mkdir -p .artoo-sdk
  echo "Downloading $name" >&2
  curl -fL --retry 3 "https://github.com/Thernal/artoo/releases/download/release/v$version/$name.tar.zst" |
    tar -C .artoo-sdk --zstd -xf -
fi
rust=$(sed -n 's/^rustc=rustc \([^ ]*\).*/\1/p' ".artoo-sdk/$name/sdk.txt")
rustup toolchain install "$rust" --profile minimal --target "$target" >&2
echo ".artoo-sdk/$name"
