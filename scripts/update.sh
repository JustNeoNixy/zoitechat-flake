#!/usr/bin/env bash
# Resolve the latest ZoiteChat release and refresh sources.json.
set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

tag=$(curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
  https://api.github.com/repos/ZoiteChat/zoitechat/releases/latest | jq -r .tag_name)
version=${tag#v}

current=$(jq -r .rev sources.json)
if [ "$tag" = "$current" ]; then
  echo "Already at $tag"
  exit 0
fi

hash=$(nix flake prefetch "github:ZoiteChat/zoitechat/$tag" --json | jq -r .hash)

jq --arg v "$version" --arg r "$tag" --arg h "$hash" \
  '.version=$v | .rev=$r | .hash=$h' sources.json > sources.json.tmp
mv sources.json.tmp sources.json
echo "Updated to $tag ($hash)"
