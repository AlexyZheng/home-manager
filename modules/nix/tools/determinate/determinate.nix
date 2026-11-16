{ inputs, ... }:
{
  flake.modules.nixos.determinate = {
    imports = [ inputs.determinate.nixosModules.default ];
  };
}
