{
  inputs,
  ...
}:
{
  flake.modules.nixos.VPS = {
    imports = with inputs.self.modules.nixos; [
      system-cli
      systemd-boot
    ];
  };
  ###
}
