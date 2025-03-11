let
  sources = {
    nixpkgs = <nixpkgs>;
  };
in

import ../default.nix { inherit sources; } {
  imports = [ ./packages.nix ];
}
