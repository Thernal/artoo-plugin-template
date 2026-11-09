# An Artoo plugin

A starting point for a plugin of [Artoo](https://github.com/Thernal/artoo). It adds a tool window, and offers a small
service to other plugins. Make your own repository from it with **Use this template**.

A plugin is a native library that runs inside Artoo with the app's full rights, so people install one only if they
trust who made it.

## Build

Rename the package in `Cargo.toml`: its name is the plugin's id. Set `repository` too, it is what Settings → Plugins
links to, where a crash report goes, and the only place an update of your plugin is accepted from. List the Artoo releases you support in `artoo-versions.txt`, one per line.

```sh
sh scripts/build.sh
```

The first build downloads that release's SDK and the exact Rust compiler it was built with, about 200 MB, into
`.artoo-sdk/`. A plugin must be built against the very Artoo it runs in, so each Artoo release needs its own build.

On macOS, build on Apple silicon; both Mac architectures can be built from there.

On Linux, the build needs the development packages of what Artoo links with: `libxkbcommon-dev libxkbcommon-x11-dev
libxcb1-dev libfontconfig1-dev libfreetype-dev`.

## Run it in Artoo

No repository or release is needed. In Artoo, open Settings → Plugins → Local, choose **Add…** and pick this folder.
After each build, **Restart Artoo** runs what you built. Its row shows it as `local`, and says why if it was not loaded.

To start Artoo from a terminal instead, point `ARTOO_PLUGIN_DEV` at the library, or at a folder of them:

```sh
ARTOO_PLUGIN_DEV="$PWD/$(sh scripts/build.sh)" /Applications/Artoo.app/Contents/MacOS/Artoo
```

Build against the same Artoo release you run it in: list it first in `artoo-versions.txt`.

## Publish

1. Give the repository the topic `artoo-plugin`, which is how Artoo finds it.
2. Push a tag such as `v0.1.0`. The workflow builds every target for every release in `artoo-versions.txt` and attaches
   `<id>-<artoo-version>-<target>.zip` to a GitHub release.

When Artoo ships a new release, add it to `artoo-versions.txt` and tag again: a plugin with no build for a release stays
off there until it has one.
