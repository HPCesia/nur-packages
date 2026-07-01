{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.forgejo-runner;
  settingsFormat = pkgs.formats.yaml {};

  # Check whether any runner instance label requires a container runtime
  # Empty label strings result in the upstream defined defaultLabels, which require docker
  # https://gitea.com/gitea/act_runner/src/tag/v0.1.5/internal/app/cmd/register.go#L93-L98
  _hasDockerScheme = x: x.labels == [] || lib.any (label: lib.hasInfix ":docker:" label) x.labels;
  hasDockerScheme = instance: _hasDockerScheme instance || lib.any _hasDockerScheme (lib.attrValues instance.servers);
  wantsContainerRuntime = lib.any hasDockerScheme (lib.attrValues cfg.instances);

  _hasHostScheme = x: lib.any (label: lib.hasSuffix ":host" label) x.labels;
  hasHostScheme = instance: _hasHostScheme instance || lib.any _hasHostScheme (lib.attrValues instance.servers);

  # provide shorthands for whether container runtimes are enabled
  hasDocker = config.virtualisation.docker.enable;
  hasPodman = config.virtualisation.podman.enable;

  _tokenXorTokenFile = server:
    (server.token == null && server.tokenFile != null)
    || (server.token != null && server.tokenFile == null);
  tokenXorTokenFile = instance: (lib.attrValues instance.servers) == [] || lib.any _tokenXorTokenFile (lib.attrValues instance.servers);

  utils = pkgs.callPackage "${pkgs.path}/nixos/lib/utils.nix" {};
in {
  options.services.forgejo-runner = {
    package = lib.mkPackageOption pkgs "forgejo-runner" {};

    instances = lib.mkOption {
      default = {};
      description = ''
        Forgejo Runner instances
      '';
      type = lib.types.attrsOf (lib.types.submodule ({
        name,
        config,
        ...
      }: {
        options = {
          enable = lib.mkEnableOption "Forgejo Runner instance";

          name = lib.mkOption {
            type = lib.types.str;
            example = lib.literalExpression "config.networking.hostName";
            default = name;
            description = ''
              The name identifying the runner instance towards the Gitea/Forgejo instance.
            '';
          };

          servers = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  example = "codeberg";
                  default = name;
                  description = ''
                    The name identifying the runner instance towards the Gitea/Forgejo instance.
                  '';
                };

                url = lib.mkOption {
                  type = lib.types.str;
                  example = "https://forge.example.com";
                  description = ''
                    Base URL of your Gitea/Forgejo instance.
                  '';
                };

                uuid = lib.mkOption {
                  type = lib.types.str;
                  example = "c9e50be9-a7c3-4aee-ba35-624c4ff8c519";
                  description = ''
                    Base URL of your Gitea/Forgejo instance.
                  '';
                };

                token = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = ''
                    Plain token to register at the configured Gitea/Forgejo instance.
                  '';
                };

                tokenFile = lib.mkOption {
                  type = lib.types.nullOr (lib.types.either lib.types.str lib.types.path);
                  default = null;
                  description = ''
                    Path to a file contains token to register at the configured Gitea/Forgejo instance.
                  '';
                };

                labels = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  example = lib.literalExpression ''
                    [
                      # provide a debian base with nodejs for actions
                      "debian-latest:docker://node:18-bullseye"
                      # fake the ubuntu name, because node provides no ubuntu builds
                      "ubuntu-latest:docker://node:18-bullseye"
                      # provide native execution on the host
                      #"native:host"
                    ]
                  '';
                  description = ''
                    Labels used to map jobs to their runtime environment for specific instance.

                    Many common actions require bash, git and nodejs, as well as a filesystem
                    that follows the filesystem hierarchy standard.
                  '';
                };
              };
            }));
          };

          labels = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            example = lib.literalExpression ''
              [
                # provide a debian base with nodejs for actions
                "debian-latest:docker://node:18-bullseye"
                # fake the ubuntu name, because node provides no ubuntu builds
                "ubuntu-latest:docker://node:18-bullseye"
                # provide native execution on the host
                #"native:host"
              ]
            '';
            description = ''
              Labels used to map jobs to their runtime environment.

              Many common actions require bash, git and nodejs, as well as a filesystem
              that follows the filesystem hierarchy standard.
            '';
          };

          settings = lib.mkOption {
            description = ''
              Configuration for `act_runner daemon`.
              See <https://gitea.com/gitea/act_runner/src/branch/main/internal/pkg/config/config.example.yaml> for an example configuration
            '';

            type = lib.types.submodule {
              freeformType = settingsFormat.type;
              options = {
                runner.labels = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = config.labels;
                };
                server.connections = lib.mkOption {
                  type = lib.types.attrsOf (lib.types.submodule {
                    freeformType = settingsFormat.type;
                  });
                  default =
                    lib.mapAttrs (n: v: {
                      inherit (v) url uuid labels;
                      token = lib.mkIf (v.token != null) v.token;
                      token_url = lib.mkIf (v.tokenFile != null) "file://${v.tokenFile}";
                    })
                    config.servers;
                };
              };
            };
          };

          hostPackages = lib.mkOption {
            type = lib.types.listOf lib.types.package;
            default = with pkgs; [
              bash
              coreutils
              curl
              gawk
              gitMinimal
              gnused
              nodejs
              wget
            ];
            defaultText = lib.literalExpression ''
              with pkgs; [
                bash
                coreutils
                curl
                gawk
                gitMinimal
                gnused
                nodejs
                wget
              ]
            '';
            description = ''
              List of packages, that are available to actions, when the runner is configured
              with a host execution label.
            '';
          };
        };
      }));
    };
  };

  config = lib.mkIf (cfg.instances != {}) {
    assertions = [
      {
        assertion = lib.any tokenXorTokenFile (lib.attrValues cfg.instances);
        message = "Servers of instances of forgejo-runner can have `token` or `tokenFile`, not both.";
      }
      {
        assertion = wantsContainerRuntime -> hasDocker || hasPodman;
        message = "Label configuration on forgejo-runner instance requires either docker or podman.";
      }
    ];

    systemd.services = let
      mkRunnerService = name: instance: let
        wantsContainerRuntime = hasDockerScheme instance;
        wantsHost = hasHostScheme instance;
        wantsDocker = wantsContainerRuntime && config.virtualisation.docker.enable;
        wantsPodman = wantsContainerRuntime && config.virtualisation.podman.enable;
        configFile = settingsFormat.generate "config.yaml" instance.settings;
      in
        lib.nameValuePair "forgejo-runner-${utils.escapeSystemdPath name}" {
          inherit (instance) enable;
          description = "Forgejo Runner";
          wants = ["network-online.target"];
          after =
            [
              "network-online.target"
            ]
            ++ lib.optionals wantsDocker [
              "docker.service"
            ]
            ++ lib.optionals wantsPodman [
              "podman.service"
            ];
          wantedBy = [
            "multi-user.target"
          ];
          environment =
            lib.optionalAttrs wantsPodman {
              DOCKER_HOST = "unix:///run/podman/podman.sock";
            }
            // {
              HOME = "/var/lib/forgejo-runner/${name}";
            };
          path = with pkgs;
            [
              coreutils
            ]
            ++ lib.optionals wantsHost instance.hostPackages;
          serviceConfig = {
            DynamicUser = true;
            StateDirectory = "forgejo-runner";
            WorkingDirectory = "-/var/lib/forgejo-runner/${name}";

            Restart = "on-failure";
            RestartSec = 2;

            ExecStart = "${cfg.package}/bin/act_runner daemon --config ${configFile}";
            SupplementaryGroups =
              lib.optionals wantsDocker [
                "docker"
              ]
              ++ lib.optionals wantsPodman [
                "podman"
              ];
          };
        };
    in
      lib.mapAttrs' mkRunnerService cfg.instances;
  };
}
