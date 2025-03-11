# cores

> [!WARNING]
> I made this on a whim in an afternoon. It's not production ready and may never be. Here be dragons! 🐲

Your Nix code, in ~~modules~~ cores!

## What does it do?

`cores` brings the module system from NixOS right into your stable Nix code. This comes with a few big advantages, like:

- No more manual importing of files
- Improved re-usability of code
- Self documenting interfaces
- Less boilerplate
- A lot of composability!

## Usage

`cores` is best used with tools like [`npins`](https://github.com/andir/npins) and [`niv`](https://github.com/nmattia/niv). In this example, we'll use the former:

```console
$ npins init
$ npins add github --branch main getchoo cores
```

Then create a `default.nix`:

```nix
let
  sources = import ./npins;
in

import sources.cores { inherit sources; } {
  outputs = {
    hello = "this is cores!";
  };
}
```

## Why?

As someone who primarily uses Flakes, one of my favorite parts of them for a while has been [flake-parts](https://github.com/hercules-ci/flake-parts). There isn't much of an equivalent in stable Nix for it's functions though, so after a couple [social media](https://hachyderm.io/@jakehamilton/114126394605099447) [posts](https://wetdry.world/@getchoo/114129209075883077) and taking inspiration from [previous work I've done](https://github.com/getchoo/borealis/blob/90c094cb3dfd4a68bd04202695373500394ee5f4/secrets/secrets.nix), I came up with this
