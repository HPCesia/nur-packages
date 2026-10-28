{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  unstableGitUpdater,
  bash,
  bc,
  cacert,
  clinfo,
  coreutils,
  curl,
  curl-impersonate,
  dmidecode,
  findutils,
  fio,
  gawk,
  geekbench_5,
  glibc,
  gnugrep,
  gnused,
  gnutar,
  iproute2,
  jq,
  kmod,
  lm_sensors,
  ncurses,
  nvme-cli,
  pciutils,
  procps,
  smartmontools,
  sysbench,
  util-linux,
  enableGeekBench ? true,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hardware-quality";
  version = "0-unstable-2026-07-15";

  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "xykt";
    repo = "HardwareQuality";
    rev = "06f99880d516bb744afa2948261b9697c79789e2";
    hash = "sha256-roxfN8+gRJvwZITJ1lXZhXjCUP0HkSZQmRMBV2Jm3qU=";
  };

  nativeBuildInputs = [makeWrapper];
  dontConfigure = true;
  dontBuild = true;

  runtimeDeps =
    [
      bash
      bc
      clinfo
      coreutils
      curl
      curl-impersonate
      dmidecode
      findutils
      fio
      gawk
      glibc.bin
      gnugrep
      gnused
      gnutar
      iproute2
      jq
      kmod
      lm_sensors
      ncurses
      nvme-cli
      pciutils
      procps
      smartmontools
      sysbench
      util-linux
    ]
    ++ lib.optionals enableGeekBench [geekbench_5];

  installPhase = ''
    runHook preInstall

    install -Dm0755 hardware.sh $out/share/hardware-quality/hardware.sh

    makeWrapper ${lib.getExe bash} $out/bin/hardware-quality \
      --add-flags $out/share/hardware-quality/hardware.sh \
      --add-flags "-n" \
      --prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps} \
      --set-default SSL_CERT_FILE ${cacert}/etc/ssl/certs/ca-bundle.crt

    runHook postInstall
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    description = "Hardware quality check script for Linux servers and VPS";
    homepage = "https://github.com/xykt/HardwareQuality";
    license = lib.licenses.agpl3Only;
    mainProgram = "hardware-quality";
    platforms = lib.platforms.linux;
  };
})
