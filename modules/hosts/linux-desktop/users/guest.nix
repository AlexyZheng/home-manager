{
  inputs,
  self,
  ...
}:
{
  flake.modules.nixos.linux-desktop =
    { config, ... }:
    {
      imports =
        with inputs.self.modules.nixos;
        with inputs.self.factory;
        [
          guest
          (mount-cifs-nixos {
            host = "home-server.lan";
            resource = "home";
            destination = "/home/users/guest/homeserver";
            credentialspath = "${config.age.secrets."homeserver-cred".path}";
            UID = "guest";
            GID = "users";
          })
        ];

      age.secrets."homeserver-cred" = {
        file = "${self.inputs.secrets}/homeserver-cred.age";
      };

      # ...

      home-manager.users.guest = {
        ###
      };
    };
}
