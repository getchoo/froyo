{
  config,
  lib,
  options,
  inputs,
  ...
}:

let
  # Normalize a string or singular platform into a `{build,host}Platform` suitable for Nixpkgs
  normalizeTarget = target: rec {
    buildPlatform = lib.systems.elaborate target.buildPlatform or target;
    hostPlatform =
      if target ? "hostPlatform" then lib.systems.elaborate target.hostPlatform else buildPlatform;
  };

  # Define the public API for it
  targetSubmodule =
    { lib, options, ... }:

    {
      options = {
        buildPlatform = lib.mkOption {
          type = lib.types.attrs;
        };

        hostPlatform = lib.mkOption { inherit (options.buildPlatform) type; };
      };
    };
in

{
  options = {
    perTarget = lib.mkOption {
      description = "A module applied over each configured `target`. Individual targets can be further customized with `allTargets`.";
      type = lib.types.deferredModuleWith {
        staticModules = [
          (
            { lib, ... }:

            {
              options = {
                target = lib.mkOption {
                  type = lib.types.submodule targetSubmodule;
                };

                outputs = lib.mkOption {
                  inherit (options.outputs) description type default;
                };
              };
            }
          )
        ];
      };
      default = { };
    };

    targets = lib.mkOption {
      description = "Attribute set describing targets `froyo` considers by default.";
      type = lib.types.attrsOf (
        lib.types.oneOf [
          # Single elaborated system, or full {build,host}Platform combination
          (lib.types.attrsOf lib.types.anything)
          # Single string system that needs to be elaborated on
          lib.types.str
        ]
      );
      apply = lib.mapAttrs (lib.const normalizeTarget);
    };

    noDefaultTargets = lib.mkOption {
      description = "Whether to use the default targets (x86_64-linux, aarch64-linux, x86_64-darwin, aarch64-darwin).";
      type = lib.types.bool;
      default = false;
    };

    allTargets = lib.mkOption {
      description = "Collection of partially evaluated submodules for each target, with `perTarget` already applied.";
      type = lib.types.attrsOf (
        lib.types.submoduleWith {
          modules = [ config.perTarget ];
          specialArgs = { inherit inputs; };
        }
      );
      default = { };
    };
  };

  config = {
    targets = lib.mkIf (!config.noDefaultTargets) {
      inherit (lib.systems.examples)
        aarch64-darwin
        x86_64-darwin
        ;

      aarch64-linux = "aarch64-linux";
      x86_64-linux = "x86_64-linux";
    };

    allTargets = lib.mapAttrs (lib.const (target: {
      inherit target;
    })) config.targets;

    outputs = {
      perTarget = lib.mapAttrs (lib.const (lib.getAttr "outputs")) config.allTargets;
    };
  };
}
