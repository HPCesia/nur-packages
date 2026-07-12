{
  lib,
  pkgs,
  config,
  ...
}: let
  utils = pkgs.callPackage "${pkgs.path}/nixos/lib/utils.nix" {};

  cfg = config.services.mihomo;

  # mihomo use YAML as config format, but set to JSON for secret inject
  configFormat = pkgs.formats.json {};

  AmbientCapabilities =
    lib.optional cfg.tunMode "CAP_NET_ADMIN"
    ++ lib.optionals cfg.processesInfo [
      "CAP_DAC_READ_SEARCH"
      "CAP_SYS_PTRACE"
    ];
  CapabilityBoundingSet = AmbientCapabilities;
in {
  disabledModules = ["services/networking/mihomo.nix"];

  options.services.mihomo = {
    enable = lib.mkEnableOption "Mihomo, A rule-based proxy in Go";

    package = lib.mkPackageOption pkgs "mihomo" {};

    config = lib.mkOption {
      type = lib.types.submodule {
        freeformType = configFormat.type;
        options = {
          tun.enable = lib.mkOption {
            default = cfg.tunMode;
            type = lib.types.bool;
            example = true;
            description = "Enable mihomo's tun mode";
          };
        };
      };
      default = {};
      description = ''
        The mihomo configuration, see <https://wiki.metacubex.one/en/config/> for documentation.

        Options containing secret data should be set to an attribute set
        containing the attribute `_secret` - a string pointing to a file
        containing the value the option should be set to.

        Set `quote = true` (default behavior) to quote the content of the
        secret file as a string, or set `quote = false` to parse the content
        of the secret file to JSON.
      '';
    };

    webui = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.path;
      example = lib.literalExpression "pkgs.metacubexd";
      description = ''
        Local web interface to use.

        You can also use the following website:
        - metacubexd:
          - <https://d.metacubex.one>
          - <https://metacubex.github.io/metacubexd>
          - <https://metacubexd.pages.dev>
        - yacd:
          - <https://yacd.haishan.me>
        - clash-dashboard:
          - <https://clash.razord.top>
      '';
    };

    extraOpts = lib.mkOption {
      default = null;
      type = lib.types.nullOr lib.types.str;
      description = "Extra command line options to use.";
    };

    tunMode = lib.mkEnableOption ''
      necessary capabilities for Mihomo's systemd service for TUN mode to function properly.
    '';

    processesInfo = lib.mkEnableOption ''
      necessary capabilities for rules about process information such as `process-name`
    '';
  };

  config = lib.mkIf cfg.enable {
    systemd.services."mihomo" = {
      description = "Mihomo daemon, A rule-based proxy in Go.";
      documentation = ["https://wiki.metacubex.one/"];
      requires = ["network-online.target"];
      after = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig =
        {
          User = "mihomo";
          Group = "mihomo";
          StateDirectory = "mihomo";
          StateDirectoryMode = "0700";
          RuntimeDirectory = "mihomo";
          RuntimeDirectoryMode = "0700";
          WorkingDirectory = "/var/lib/mihomo";

          ExecStart = lib.concatStringsSep " " [
            (lib.getExe cfg.package)
            "-d /var/lib/mihomo"
            "-f /run/mihomo/config.yaml"
            (lib.optionalString (cfg.webui != null) "-ext-ui ${cfg.webui}")
            (lib.optionalString (cfg.extraOpts != null) cfg.extraOpts)
          ];

          ExecStartPre = "+${pkgs.writeShellScript "mihomo-pre-start" ''
            ${utils.genJqSecretsReplacementSnippet cfg.config "/run/mihomo/config.json"}
            ${lib.getExe pkgs.yq-go} --input-format 'json' --output-format 'yaml' \
                /run/mihomo/config.json > /run/mihomo/config.yaml
            rm /run/mihomo/config.json
            chown --reference=/run/mihomo /run/mihomo/config.yaml
          ''}";

          inherit AmbientCapabilities CapabilityBoundingSet;
          DeviceAllow = "";
          LockPersonality = true;
          MemoryDenyWriteExecute = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateMounts = true;
          PrivateTmp = true;
          PrivateUsers = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RestrictNamespaces = true;
          RestrictAddressFamilies = "AF_INET AF_INET6";
          SystemCallArchitectures = "native";
          SystemCallFilter = "@system-service bpf";
          UMask = "0077";
        }
        // lib.optionalAttrs cfg.tunMode {
          PrivateDevices = false;
          PrivateUsers = false;
          RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
        };
    };

    users.users.mihomo = {
      isSystemUser = true;
      group = "mihomo";
      home = "/var/lib/mihomo";
    };
    users.groups.mihomo = {};
  };
}
