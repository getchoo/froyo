{
  lib ? import <nixpkgs/lib>,
}:

lib.fix (self: {
  evalCores =
    {
      modules,
      specialArgs,
    }:

    lib.evalModules {
      modules = [ ./modules ] ++ modules;
      inherit specialArgs;
      class = "core";
    };

  mkCores =
    {
      module,
      specialArgs,
      sources,
    }:

    self.outputsWithExtend (
      self.evalCores {
        modules = [
          module

          (
            { lib, ... }:

            {
              sources = lib.mkDefault sources;
            }
          )
        ];

        inherit specialArgs;
      }
    );

  outputsWithExtend =
    cores:

    assert cores.class == "core";

    cores.config.outputs
    // {
      extendCores = module: self.outputsWithExtend (cores.extendModules { modules = [ module ]; });
    };
})
