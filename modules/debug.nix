{ lib, ... }:

{
  options.debug = lib.mkEnableOption "debug attributes in the top-level file (i.e., `options`, `config`, etc.)";
}
