{
  sources ? import ./npins,
  lib ? import (
    sources.nixpkgs
      or (throw "cores: could not find `nixpkgs` in `sources.` Please pass `lib` manually")
    + "/lib"
  ),
  specialArgs ? { },
}:

let
  coresLib = import ./lib.nix { inherit lib; };
in

module:

coresLib.mkCores { inherit module specialArgs sources; }
