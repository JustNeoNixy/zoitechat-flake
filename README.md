# zoitechat-flake

Nix flake for [ZoiteChat](https://zoitechat.org), a GTK3 IRC client based on HexChat. Built from the upstream source tag.

Unofficial. Not affiliated with the ZoiteChat project.

## Install

```
nix build .#default
./result/bin/zoitechat
```

As a flake input:

```
zoitechat = {
  url = "github:<you>/zoitechat-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

```
environment.systemPackages = [
  inputs.zoitechat.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

Or use the overlay (`nixpkgs.overlays = [ inputs.zoitechat.overlays.default ];`) and reference `pkgs.zoitechat`.

## Updating

`nix run .#update` refreshes `sources.json` to the latest release. A daily workflow does the same and opens a PR.
