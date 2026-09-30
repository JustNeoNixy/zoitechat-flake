#!/usr/bin/env bash
# Re-resolves the latest ZoiteChat release tag + source hash and rewrites
# sources.json. Run from the repo root, or via `nix run .#update`.
set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

SOURCES_JSON="sources.json"
api_url="https://api.github.com/repos/ZoiteChat/zoitechat/releases/latest"

echo "Resolving latest release tag..." >&2
if [ -n "${GITHUB_TOKEN:-}" ]; then
  tag=$(curl -fsSL -H "Authorization: Bearer $GITHUB_TOKEN" "$api_url" | jq -r .tag_name)
else
  tag=$(curl -fsSL "$api_url" | jq -r .tag_name)
fi

if [ -z "$tag" ] || [ "$tag" = "null" ]; then
  echo "Couldn't read a release tag from the GitHub API." >&2
  exit 1
fi
version=${tag#v}
echo "Latest tag: $tag" >&2

current=$(jq -r .rev "$SOURCES_JSON")
if [ "$tag" = "$current" ]; then
  echo "Already at $tag"
  exit 0
fi

hash=$(nix flake prefetch "github:ZoiteChat/zoitechat/$tag" --json | jq -r .hash)

jq --arg v "$version" --arg r "$tag" --arg h "$hash" \
  '.version=$v | .rev=$r | .hash=$h' "$SOURCES_JSON" > "$SOURCES_JSON.tmp"
mv "$SOURCES_JSON.tmp" "$SOURCES_JSON"

echo "Wrote $SOURCES_JSON:" >&2
cat "$SOURCES_JSON"
echo "Updated to $tag ($hash)" >&2
