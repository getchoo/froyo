{
  outputs = _: {
    lib.new = import ./default.nix;
  };
}
