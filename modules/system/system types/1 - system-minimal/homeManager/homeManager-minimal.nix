{
  # default settings needed for all homeManagerConfigurations

  flake.modules.homeManager.system-minimal =
    {
      config,
      ...
    }:
    {
      home.homeDirectory =
        if config.home.username == "root" then
          "/root"
        else
          "/home/${config.home.username}";
      home.stateVersion = "26.05";
    };
}
