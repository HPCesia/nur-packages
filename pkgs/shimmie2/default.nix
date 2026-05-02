{
  writeShellApplication,
  bubblewrap,
  php,
  shimmie2-unwrapped,
  defaultDataDir ? "$HOME/.shimmie2",
}:
writeShellApplication {
  name = "shimmie2";

  derivationArgs = {
    inherit (shimmie2-unwrapped) meta version;
  };

  runtimeInputs = [bubblewrap php];
  text = ''
    show_help() {
      cat <<EOF
    Usage: shimmie2 [OPTIONS]

    Wrapper of shimmie2, an easy-to-install community image gallery (aka booru)

    Options:
      -h, --help                Show this help message
      -a, --address ADDRESS     Set the service address (default: 127.0.0.1:9000)
      -d, --data-dir DIR        Set the data directory mapping (default: ${defaultDataDir})
      --                        Pass all subsequent arguments directly to the PHP process

    Example:
      shimmie2 -a 0.0.0.0:9000 -- -d upload_max_filesize=100M -d post_max_size=100M
    EOF
    }

    ADDRESS="127.0.0.1:9000"
    DATA_DIR="${defaultDataDir}"
    PHP_ARGS=()

    while [[ "$#" -gt 0 ]]; do
      case $1 in
        -h|--help)
          show_help
          exit 0
          ;;
        -a|--address)
          ADDRESS="$2"
          shift
          ;;
        -d|--data-dir)
          DATA_DIR="$2"
          shift
          ;;
        --)
          shift
          PHP_ARGS=("$@")
          break
          ;;
        *)
          echo "Unknown parameter: $1"
          show_help
          exit 1
          ;;
      esac
      shift
    done

    mkdir -p "$DATA_DIR"

    APP_ROOT="${shimmie2-unwrapped}/share/php/${shimmie2-unwrapped.pname}"

    echo "Starting Shimmie2 on $ADDRESS..."
    echo "Mapping data dir to writeable $DATA_DIR"

    exec bwrap \
      --dev-bind / / \
      --bind "$DATA_DIR" "$APP_ROOT/data" \
      --chdir "$APP_ROOT" \
      php "''${PHP_ARGS[@]}" -S "$ADDRESS" tests/router.php
  '';
}
