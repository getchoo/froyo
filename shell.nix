{
  pkgs ? import nixpkgs {
    config = { };
    overlays = [ ];
  },
  nixpkgs ? (import ./npins).nixpkgs,
}:

let
  inherit (pkgs) lib;
in

pkgs.mkShellNoCC {
  packages = lib.attrValues {
    inherit (pkgs)
      actionlint
      deadnix
      nixfmt
      npins
      reuse
      statix
      ;
  };
}
