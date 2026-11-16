{
  flake.modules.nixos.VPS = {
    boot.kernelModules = [  ];
    boot.extraModulePackages = [ ];

    nixpkgs.hostPlatform = "aarch64-linux";
  };
}
