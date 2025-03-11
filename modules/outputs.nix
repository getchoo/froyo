{ lib, ... }:

let
  outputsSubmodule = {
    freeformType = lib.types.lazyAttrsOf lib.types.raw;
  };
in

{
  options.outputs = lib.mkOption {
    type = lib.types.submodule outputsSubmodule;
    default = { };
    description = "Outputs to pass to the top-level file.";
  };
}
