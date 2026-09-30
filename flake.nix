{
  description = "ZoiteChat (GTK3 IRC client, HexChat fork) built from source";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.callPackage ./pkgs/zoitechat.nix { };

        apps.update = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "zoitechat-update";
            runtimeInputs = [ pkgs.curl pkgs.jq pkgs.nix ];
            text = builtins.readFile ./scripts/update.sh;
          }}/bin/zoitechat-update";
          meta.description = "Update the pinned zoitechat revision in sources.json";
        };
      }) // {
      overlays.default = final: prev: {
        zoitechat = final.callPackage ./pkgs/zoitechat.nix { };
      };
    };
}
