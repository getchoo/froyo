{
  outputs =
    _:

    let
      toStandardOutputs =
        froyo:
        {
          inherit froyo;
          /*
            FIXME: This should work and be exported!

            The current implementation will properly export the extended configuration as `froyo` above,
            but the following `outputs` and `perTarget` attributes remain untouched.

            Why???? I have no idea. Maybe Nix lang is doing some caching nonsense? -getchoo
          */
          # extend = module: toStandardOutputs (froyo.extend module);
        }
        // builtins.removeAttrs froyo.outputs [ "perTarget" ]
        // builtins.foldl' (
          acc: system:
          acc // builtins.mapAttrs (_: value: { ${system} = value; }) froyo.outputs.perTarget.${system}
        ) { } (builtins.attrNames froyo.outputs.perTarget);
    in

    {
      lib = {
        new = import ./default.nix;
        inherit toStandardOutputs;
      };
    };
}
