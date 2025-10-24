# froyo

> [!CAUTION]
> I made this on a whim in an afternoon. It's not production ready and may never be. Here be dragons! 🐲

## What does it do?

`froyo` brings the module system from NixOS right into your stable Nix code. This comes with a few big advantages, like:

- No more manual importing of files
- Improved re-usability of code
- Self documenting interfaces
- Less boilerplate
- A lot of composability!

## Usage

### Quick Start

> [!WARNING]
> `froyo` is best used with tools like [`npins`](https://github.com/andir/npins) and [`niv`](https://github.com/nmattia/niv).

```nix
import <froyo> { } {
  outputs = {
    hello = "hi from froyo!";
  };
}
```

```console
$ nix-instantiate --eval --attr outputs.hello
```

### With pinned sources

By default, `froyo` will use it's own Nixpkgs when applicable. However, **it is highly recommended to maintain your own lockfile with Nixpkgs** and pass that to `froyo` directly.

```nix
let
  # In this example we use `npins`, but these could come from anything (even channels!)
  inputs = import ./npins;
in

import inputs.froyo { inherit inputs; } {
  outputs = {
    hello = "hi from froyo!";
  };

  perTarget =
    { pkgs, ... }:

    {
      outputs = { inherit (pkgs) hello; };
    };
}
```

You can then build this `hello` package:

```console
$ nix-build --attr outputs.perTarget.x86_64-linux.hello
```

### With flakes

`froyo` also works with flakes!

```nix
{
  inputs = {
    nixpkgs.url = "https://nixpkgs.dev/channel/nixos-unstable";
    froyo.url = "github:getchoo/froyo";
  };

  outputs =
    inputs:

    let
      inherit (inputs.froyo.lib) new toStandardOutputs;

      result = new { inherit inputs; } {
        perTarget =
          { pkgs, ... }:

          {
            outputs = {
              packages = { inherit (pkgs) hello; };
            };
          };
      };
    in

    # This exports everything from `outputs` as flake outputs.
    # Then, it transforms `perTarget.<system>.<attr>` attributes into
    # `<attr>.<system>` - like the flake schema expects
    #
    # It also re-exports the entire froyo project as the output `froyo`
    toStandardOutputs result;
}
```

You can then use this like any other flake:

```console
$ nix build '.#hello'
```

## Concepts

### Inputs and Outputs

`froyo` projects can be boiled down to two things: inputs and outputs.

#### Inputs

Inputs are sources (usually managed by tools like `npins`, `niv`, etc.) passed to `froyo` projects. They can be local (/nix/store) paths, instantiated package sets, or even flake inputs!

#### Outputs

Outputs are pieces of your Nix code meant to be used by the outside world. This is represented by the `outputs` config option, which (along with `inputs`) are the only fields exported by `froyo`.

### "Targets"

To assist in both common and more exotic workflows, `froyo` introduces the concept of "targets". Targets are either:

- A string describing a system recognized by Nixpkgs (i.e., `"x86_64-linux"` or `"aarch64-darwin"`)
- An attribute set describing a system (such as those created with `lib.systems.elaborate`)
- An attribute set containing a `buildPlatform` and `hostPlatform` attribute (with a value of one of the above) for cross compilation

> [!TIP]
> Sound familiar?!
> This is analogous to the `system` variable commonly used in flakes, but expanded upon to consider multiple systems

`targets` is the name-value pair option used to describe the targets `froyo` operates on by default, like so:

```nix
{ config, lib, ... }:

{
  targets = {
    x86_64-linux = lib.systems.elaborate "x86_64-linux";
    inherit (lib.systems.examples) aarch64-darwin;
    aarch64-cross = {
      buildPlatform = config.targets.x86_64-linux;
      hostPlatform = "aarch64-linux";
    };
  };
}
```

#### `perTarget`

`perTarget` is a small helper option defined in [`modules/per-target.nix`](./modules/per-target.nix). It allows you to define attributes that will be applied to each target defined by the aforementioned `targets` option.

```nix
{
  perTarget = { pkgs, ... }: {
    # Similar to at the root level, you need to use `outputs` to export attributes
    outputs = { inherit (pkgs) hello; };
  };
}
```

This is then available in the final project as `outputs.perTarget.<target name>.hello`.

## Advanced Usage

### Cross compilation

The biggest advantage of using `target` over `system` is the ability for `froyo` to describe cross-compilation configurations. You can do this by defining a `buildPlatform` and `hostPlatform`.

```nix
import inputs.froyo { } {
  targets = {
    riscv-cross = {
      buildPlatform = "x86_64-linux";
      hostPlatform = "riscv64-linux";
    };
  };

  perTarget =
    { pkgs, ... }:

    {
      outputs = { inherit (pkgs) hello; };
    };
}
```

Now, a cross-compiled `hello` will be available as `outputs.perTarget.riscv-cross.hello`.

### Extending

`froyo` project can be extended - similar to using `extendModules` in NixOS configurations

```nix
let
  # Assuming we're using the above example
  my-froyo-project = import ./my-froyo-project;

  extended = my-froyo-project.extend {
    # This makes `perTarget` iterate over the new one defined here
    targets = {
      native-riscv = "riscv64-linux";
    };

    allSystems = {
      my-other-cool-target =
        { pkgs, ... }:

        {
          target = "powerpc64-linux";

          outputs = { inherit (pkgs) hello-go; };
        };
    };
  };
in

{
  # `native-riscv` is now in `perTarget`!
  inherit (extended.outputs.perTarget.native-riscv) hello;
  # `my-other-cool-target` now also exists, and has a special `hello-go` attribute exclusive to it
  inherit (extended.outputs.perTarget.my-other-cool-target) hello-go;
}
```

## Why?

As someone who primarily uses Flakes, one of my favorite parts of them for a while has been [flake-parts](https://github.com/hercules-ci/flake-parts). There isn't much of an equivalent in stable Nix for its functions though, so after a couple [social media](https://hachyderm.io/@jakehamilton/114126394605099447) [posts](https://wetdry.world/@getchoo/114129209075883077) and taking inspiration from [previous work I've done](https://github.com/getchoo/borealis/blob/90c094cb3dfd4a68bd04202695373500394ee5f4/secrets/secrets.nix), I came up with this
