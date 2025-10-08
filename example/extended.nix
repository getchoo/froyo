# This is an example of importing and extending a froyo project - in this case, for cross-compiling to riscv64
let
  froyo = import ./default.nix;
in

froyo.extend (
  { config, ... }:

  {
    targets = {
      riscv64-cross = {
        inherit (config.targets.x86_64-linux) buildPlatform;
        hostPlatform = "riscv64-linux";
      };
    };

    allTargets.ppc64-cross =
      { pkgs, ... }:

      {
        target = {
          inherit (config.targets.x86_64-linux) buildPlatform;
          hostPlatform = "powerpc64-linux";
        };

        outputs = { inherit (pkgs) hello-go; };
      };
  }
)
