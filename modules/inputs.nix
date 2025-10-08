{ config, lib, ... }:

let
  inputsSubmodule = {
    freeformType = lib.types.lazyAttrsOf lib.types.raw;
  };
in

{
  options.inputs = lib.mkOption {
    type = lib.types.submodule inputsSubmodule;
    default = { };
    description = "Inputs used across modules.";
    example = lib.literalExpression "import ./npins";
  };

  config = {
    _module.args = { inherit (config) inputs; };
  };
}
