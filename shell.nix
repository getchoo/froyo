{
  pkgs ? import <nixpkgs> {
    config = { };
    overlays = [ ];
  },
}:

pkgs.mkShellNoCC {
  packages = builtins.attrValues {
    inherit (pkgs)
      deadnix
      nixfmt-rfc-style
      npins
      statix
      ;
  };
}
