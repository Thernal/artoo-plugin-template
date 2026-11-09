#!/bin/sh
# build.sh [debug|release] [<artoo-version>] [<target>]: builds the plugin against that Artoo release's SDK, and prints
# the library's path. The version defaults to the first line of artoo-versions.txt. Set ARTOO_SDK to an unpacked SDK
# folder to use that one instead of a release's.
set -e
cd "$(dirname "$0")/.."
profile=${1:-debug}
version=${2:-$(head -1 artoo-versions.txt)}
target=${3:-$(rustc -vV | sed -n 's/^host: //p')}
if [ -n "$ARTOO_SDK" ]; then
  sdk=$ARTOO_SDK
else
  sdk=$(sh scripts/fetch-sdk.sh "$version" "$target")
fi
build=$(sed -n 's/^build=//p' "$sdk/sdk.txt")
rust=$(sed -n 's/^rustc=rustc \([^ ]*\).*/\1/p' "$sdk/sdk.txt")
case "$target" in
  *apple*) lib=libartoo_plugin_sdk.dylib prefix=lib ext=dylib ;;
  *windows*) lib=artoo_plugin_sdk.dll prefix= ext=dll ;;
  *) lib=libartoo_plugin_sdk.so prefix=lib ext=so ;;
esac
# The SDK's identity is in the flags so Cargo rebuilds when it changes; separated by 0x1f, so a path may hold spaces.
us=$(printf '\037')
CARGO_ENCODED_RUSTFLAGS="-L${us}dependency=$sdk/deps${us}-L${us}native=$sdk/deps${us}--extern${us}artoo_plugin_sdk=$sdk/deps/$lib${us}--cfg${us}artoo_sdk_build=\"$build\"${us}--check-cfg${us}cfg(artoo_sdk_build,values(any()))"
export CARGO_ENCODED_RUSTFLAGS
export ARTOO_SDK_BUILD=$build
flag=
[ "$profile" = release ] && flag=--release
# Always with `--target`: these flags then reach the plugin, not its build scripts and proc macros.
cargo "+$rust" build -q $flag --target "$target"
name=$(sed -n 's/^name = "\(.*\)"/\1/p' Cargo.toml | head -1 | tr - _)
echo "target/$target/$profile/$prefix$name.$ext"
