{ supportedPlatforms ? [ "x86_64-linux" "x86_64-darwin" ]
}:

let
  genAttrs = (import <nixpkgs> {}).lib.genAttrs;
in
{
  build = genAttrs supportedPlatforms (system:
    with (import <nixpkgs> { inherit system; });
    callPackage ./default.nix {
      inherit (haskellPackages) ghc;
      inherit (haskellPackages_ghcHEAD) alex happy;
    }
  );
}
