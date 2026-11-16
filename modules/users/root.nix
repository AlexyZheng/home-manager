{
  inputs,
  ...
}:

let
  username = "root";
in
{
  flake.modules.nixos."${username}" =
    {
      pkgs,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [
        # developmentEnvironment
      ];

      home-manager.users."${username}" = {
        imports = [
          inputs.self.modules.homeManager."${username}"
        ];
      };

      users.users."${username}" = {
        shell = pkgs.zsh;
      };
      programs.zsh.enable = true;
    };

  flake.modules.homeManager."${username}" =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        system-cli
        # drawing
      ];
      home.username = "${username}";
      home.homeDirectory = "/root";
      home.packages = with pkgs; [
        imagemagick
      ];
    };
}
