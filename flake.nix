{
  description = "Flake for my homepage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self }: {
    nixosModules.default = { config, lib, ... }:
      with lib;
      let
        cfg = config.services.kelwing-homepage;
      in {
        options.services.kelwing-homepage = {
          enable = mkEnableOption "static site server";

          virtualHost = mkOption {
            type = types.str;
            default = "localhost";
            description = "Virtual host name for the static site";
          };

          extraVirtualHostConfig = mkOption {
            type = types.attrs;
            default = {};
            description = "Extra configuration for the nginx virtual host (listen, SSL, etc.)";
            example = literalExpression ''
              {
                listen = [ { addr = "0.0.0.0"; port = 80; } ];
                enableACME = true;
                forceSSL = true;
              }
            '';
          };
        };

        config = mkIf cfg.enable {
          services.nginx.virtualHosts.${cfg.virtualHost} = mkMerge [
            {
              root = self;
              locations."/" = {
                index = "index.html";
                tryFiles = "$uri $uri/ =404";
              };
            }
            cfg.extraVirtualHostConfig
          ];
        };
      };
  };
}
