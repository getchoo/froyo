{ config, lib, ... }:

let
  sourcesSubmodule = {
    freeformType = lib.types.lazyAttrsOf lib.types.raw;
  };
in

{
  options.sources = lib.mkOption {
    type = lib.types.submodule sourcesSubmodule;
    default = { };
    description = "Sources used across modules.";
    example = lib.literalExpression "import ./npins";
  };

  config = {
    _module.args = { inherit (config) sources; };
  };
}
