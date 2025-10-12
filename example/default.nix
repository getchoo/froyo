# This is an example of the entrypoint to a froyo project
let
  inputs = {
    nixpkgs = <nixpkgs>;
  };
in

import ../default.nix { inherit inputs; } {
  imports = [ ./packages.nix ];
}
