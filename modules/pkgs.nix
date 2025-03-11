{ config, lib, ... }:

{
  options.pkgs = lib.mkOption {
    type = lib.types.nullOr (lib.types.lazyAttrsOf lib.types.raw);
    default =
      if (config.sources ? "nixpkgs") then
        import config.sources.nixpkgs {
          config = { };
          overlays = [ ];
        }
      else
        null;
    defaultText = "if (sources has nixpkgs) import sources.nixpkgs { ... } else null";
    description = "The instance of `nixpkgs` to pass as a module argument.";
    example = lib.literalExpression "import <nixpkgs> { config = { allowUnfree = true; }; }";
  };

  config = {
    _module.args = { inherit (config) pkgs; };
  };
}
