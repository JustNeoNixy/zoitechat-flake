# zoitechat-flake

Nix flake for ZoiteChat, a GTK3 IRC client based on HexChat.

Unofficial. Not affiliated with the ZoiteChat project.

## Install

Build and run it directly:

```bash
nix build .#default
./result/bin/zoitechat
```

Or add it to your system flake. Add this block under `inputs`:

```nix
zoitechat = {
  url = "github:JustNeoNixy/zoitechat-flake";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Then reference `inputs.zoitechat.packages.${system}.default` wherever you build your package set, for example:

```nix
packages = builtins.mapAttrs (system: pkgs: {
  zoitechat = inputs.zoitechat.packages.${system}.default;
  # ...your other packages
}) inputs.nixpkgs.legacyPackages;
```

Or, inside a NixOS module (your `nixosSystem` call needs `specialArgs = { inherit inputs; };` for `inputs` to be available in `configuration.nix`):

```nix
environment.systemPackages = [
  inputs.zoitechat.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

If you'd rather use the overlay so it shows up as `pkgs.zoitechat`, add this instead:

```nix
nixpkgs.overlays = [ zoitechat.overlays.default ];
```

and reference it as `pkgs.zoitechat`.
