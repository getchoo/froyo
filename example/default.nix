# This is an example of the entrypoint to a froyo project
{
  inputs ? {
    nixpkgs = <nixpkgs>;
  },
}:

import ../default.nix { inherit inputs; } {
  imports = [ ./packages.nix ];
}
