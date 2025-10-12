let
  class = "froyo";
in

{
  inputs ? import ./npins,
  lib ? import (
    inputs.nixpkgs
      or (throw "${class}: could not find `nixpkgs` in `inputs.` Please pass `lib` manually")
    + "/lib"
  ),
}:

let
  ioWithExtend =
    eval:

    assert lib.assertMsg (
      eval.class == class
    ) "ioWithExtend: evaluated configuration is not of class '${class}'";

    (
      if eval.config.debug then
        eval
      else
        {
          inherit (eval.config) inputs outputs;
        }
    )
    // {
      extend = module: ioWithExtend (eval.extendModules { modules = [ module ]; });
    };
in

module:

ioWithExtend (
  lib.evalModules {
    inherit class;
    modules = [
      ./modules
      module

      (
        { lib, ... }:

        {
          inputs = lib.mkDefault inputs;
        }
      )
    ];
  }
)
