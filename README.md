# zoitechat-flake

Nix flake for [ZoiteChat](https://zoitechat.org), a GTK3 IRC client based on HexChat. Built from the upstream source tag.

Unofficial. Not affiliated with the ZoiteChat project.

## Install

Build and run it directly:

```
nix build .#default
./result/bin/zoitechat
```

As a flake input, add this block under `inputs`:

```nix
zoitechat = {
  url = "github:JustNeoNixy/zoitechat-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then reference it wherever you build your package set:

```nix
environment.systemPackages = [
  inputs.zoitechat.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

That also installs a desktop entry, so ZoiteChat shows up in your app launcher.

Or use the overlay (`nixpkgs.overlays = [ inputs.zoitechat.overlays.default ];`) and reference `pkgs.zoitechat`.

## Updating

`nix run .#update` refreshes `sources.json` to the latest release. A daily workflow does the same and opens a PR.
