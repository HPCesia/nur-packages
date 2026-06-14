{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.services.sub-store;
in {
  options.services.sub-store = {
    enable = lib.mkEnableOption "Enable sub-store, an advanced subscription manager";

    package = lib.mkPackageOption pkgs "sub-store" {};

    address = lib.mkOption {
      default = "127.0.0.1";
      type = lib.types.str;
      description = "Host the sub-store backend listen on";
    };

    port = lib.mkOption {
      default = 3000;
      type = lib.types.port;
      description = "Port the sub-store backend listen on";
    };

    frontend = {
      enable = lib.mkEnableOption "Enable sub-store's local web frontend";
      package = lib.mkPackageOption pkgs "sub-store-frontend" {};
      address = lib.mkOption {
        default = "127.0.0.1";
        type = lib.types.str;
        description = "Host the sub-store frontend listen on";
      };
      port = lib.mkOption {
        default = 3001;
        type = lib.types.port;
        description = "Port the sub-store frontend listen on";
      };
      backendPath = lib.mkOption {
        default = "/2cXaAxRGfddmGz2yx1wA";
        type = lib.types.str;
        description = "Path of backend, see <https://hub.docker.com/r/xream/sub-store/>";
      };
    };

    environment = {
      extra = lib.mkOption {
        default = {};
        type = lib.types.attrsOf lib.types.envVar;
        description = "Extra environment variables to pass to sub-store systemd service";
      };
      file = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.path;
        description = "Environment file to pass to sub-store systemd service";
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    systemd.services.sub-store = {
      enable = cfg.enable;
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      environment =
        {
          SUB_STORE_DATA_BASE_PATH = "%S/sub-store";
          SUB_STORE_BACKEND_API_HOST = cfg.address;
          SUB_STORE_BACKEND_API_PORT = toString cfg.port;
        }
        // (lib.optionalAttrs (cfg.frontend.enable) {
          SUB_STORE_FRONTEND_PATH = "${cfg.frontend.package}";
          SUB_STORE_FRONTEND_HOST = cfg.frontend.address;
          SUB_STORE_FRONTEND_BACKEND_PATH = cfg.frontend.backendPath;
        })
        // (
          if (cfg.port == cfg.frontend.port)
          then {
            SUB_STORE_BACKEND_MERGE = "true";
          }
          else {
            SUB_STORE_FRONTEND_PORT = toString cfg.frontend.port;
          }
        )
        // cfg.environment.extra;

      serviceConfig =
        {
          StateDirectory = "sub-store";
          StateDirectoryMode = "0700";
          ExecStart = "${lib.getExe cfg.package}";
          Restart = "on-failure";
          DynamicUser = true;
        }
        // (lib.optionalAttrs (cfg.environment.file != null) {
          EnvironmentFile = cfg.environment.file;
        });
    };
  };
}
