{

  flake.modules.nixos.linux-desktop =
    {
      config,
      ...
    }:
    {
      fileSystems."/" = {
        device = "/dev/sda";
      };
      services.zfs.zed.settings = {
        ZED_EMAIL_ADDR = [ config.systemConstants.adminEmail ]; # using a constant
      };
    };
}
