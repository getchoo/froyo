{
  perTarget =
    {
      config,
      lib,
      inputs,
      ...
    }:

    let
      pkgs = import inputs.nixpkgs {
        localSystem = config.target.buildPlatform;
        crossSystem = config.target.hostPlatform;

        config = { };
        overlays = [ ];
      };

    in

    {
      config = lib.mkIf (inputs ? "nixpkgs") {
        _module.args.pkgs = lib.mkDefault (
          # Flake input support
          if
            inputs.nixpkgs ? "legacyPackages"
            && lib.systems.equals config.target.buildPlatform config.target.hostPlatform
          then
            inputs.nixpkgs.legacyPackages.${config.target.hostPlatform.system} or pkgs
          else
            pkgs
        );
      };
    };
}
