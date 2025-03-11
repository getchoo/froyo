let
  sources = import ./npins;
in

# Dogfood the library
import ./default.nix { inherit sources; } (
  { lib, pkgs, ... }:

  let
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.gitTracked ./.;
    };

    # Check a minimal example
    basicTest = import ./default.nix { inherit sources; } {
      outputs = {
        foo = "bar";
      };
    };

    # Make sure extending outputs works
    extendedTest = basicTest.extendCores (
      { lib, ... }:

      {
        outputs.foo = lib.mkForce "baz";
      }
    );
  in

  assert basicTest.foo == "bar";
  assert extendedTest.foo == "baz";

  {
    outputs = {
      deadnix = pkgs.runCommand "check-deadnix" { nativeBuildInputs = [ pkgs.deadnix ]; } ''
        deadnix --exclude ${src}/npins/default.nix --fail ${src}
        touch $out
      '';

      nixfmt = pkgs.runCommand "check-nixfmt" { nativeBuildInputs = [ pkgs.nixfmt-rfc-style ]; } ''
        nixfmt --check ${src}/**.nix
        touch $out
      '';

      statix = pkgs.runCommand "check-statix" { nativeBuildInputs = [ pkgs.statix ]; } ''
        statix check --ignore 'npins/default.nix' ${src}
        touch $out
      '';

      # Make sure our demo works too
      demo-hello = ((import ./demo/default.nix).extendCores { inherit sources; }).hello;
    };
  }
)
