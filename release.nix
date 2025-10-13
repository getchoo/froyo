# Dogfood the library
import ./default.nix { } (
  { config, lib, ... }:

  let
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.gitTracked ./.;
    };

    minimal = import ./default.nix { } {
      outputs = {
        foo = "bar";
      };
    };

    # Make sure extending outputs works
    extended = minimal.extend (
      { lib, ... }:

      {
        outputs.foo = lib.mkForce "baz";
      }
    );
  in

  assert minimal.outputs.foo == "bar";
  assert extended.outputs.foo == "baz";

  {
    perTarget =
      { pkgs, name, ... }:

      {
        outputs = {
          actionlint = pkgs.runCommand "check-actionlint" { nativeBuildInputs = [ pkgs.actionlint ]; } ''
            find ${src}/.github/workflows -type f -exec actionlint {} +
            touch $out
          '';

          deadnix = pkgs.runCommand "check-deadnix" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
            deadnix --exclude ${src}/npins/default.nix --fail ${src}
            touch $out
          '';

          nixfmt = pkgs.runCommand "check-nixfmt" { nativeBuildInputs = [ pkgs.nixfmt ]; } ''
            nixfmt --check ${src}/**.nix
            touch $out
          '';

          reuse = pkgs.runCommand "check-reuse" { nativeBuildInputs = [ pkgs.reuse ]; } ''
            cd ${src} && reuse lint
            touch $out
          '';

          statix = pkgs.runCommand "check-statix" { nativeBuildInputs = [ pkgs.statix ]; } ''
            statix check --ignore 'npins/default.nix' ${src}
            touch $out
          '';

          # Make sure our example works too
          example-hello =
            (import ./example/default.nix { inherit (config) inputs; }).outputs.perTarget.${name}.hello;

          shell = import ./shell.nix { inherit pkgs; };
        };
      };
  }
)
