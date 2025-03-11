{ pkgs, ... }:

{
  outputs = {
    inherit (pkgs) hello;
  };
}
