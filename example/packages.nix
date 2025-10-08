# This is an example of a froyo module. It just exports `pkgs.hello` for each target by default
{
  perTarget =
    { pkgs, ... }:

    {
      outputs = {
        inherit (pkgs) hello;
      };
    };
}
