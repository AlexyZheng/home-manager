{
  flake.modules.homeManager.office =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    lib.mkMerge [
      {
        home.packages = with pkgs; [
          pdfarranger
          notesnook
        ];
        # settings for all systems
      }
      (lib.mkIf (pkgs.stdenv.isLinux) {
        home.packages = with pkgs; [
          libreoffice-qt6
          gimp3-with-plugins
        ];
        # NixOS settings
      })
    ];
}
