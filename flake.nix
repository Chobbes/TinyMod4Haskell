{
  description = "Haskell TinyMod4 Firmware";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        config  = {
          allowBroken = true;
          packageOverrides = pkgs: rec {
            haskellPackages = pkgs.haskellPackages.override {
              overrides = hself: hsuper:
                with pkgs.haskell.lib; rec {
                  copilot-core = dontCheck hsuper.copilot-core;
                  html-parse = doJailbreak hsuper.html-parse;
                  kvitable = doJailbreak hsuper.kvitable;
                  what4 = dontCheck (doJailbreak hsuper.what4);
                  copilot-theorem = doJailbreak hsuper.copilot-theorem;
                  copilot-language = dontCheck hsuper.copilot-language;
                  copilot = doJailbreak hsuper.copilot;
                  sketch-frp-copilot = doJailbreak hsuper.sketch-frp-copilot;
                  arduino-copilot = doJailbreak hsuper.arduino-copilot;
                  # Need bimap 0.3.3 because bimap 0.4 isn't safe haskell.
                  # copilot-theorem uses a safe haskell import of bimap.
                  bimap = hself.callPackage ./bimap.nix { };
                };
            };
          };
        };

        pkgs = import nixpkgs {
          inherit system;

          inherit config;

          # To stay in sync with Charley
          overlays = [
            (final: prev: { arduino = final.callPackage ./arduino-core.nix {}; })
            (final: prev: { gforth  = final.callPackage ./gforth.nix {}; })
          ];
        };

      in {
        devShell = pkgs.haskellPackages.shellFor {
          packages = hp: [
            (pkgs.haskellPackages.callCabal2nix "TinyMod4" ./. {})
          ];
          buildInputs = [
            pkgs.cabal-install

            pkgs.arduino
            pkgs.gforth
          ];
        };
      }
    );
}
