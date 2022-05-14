{
  description = "Haskell TinyMod4 Firmware";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = import nixpkgs { 
          inherit system;

          # For frp-arduino
          config.allowBroken = true;

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
          build-inputs = [
            pkgs.cabal-install
 
            pkgs.arduino 
            pkgs.gforth
          ];
        };
      }
    );
}
