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
  version = "0-unstable-2026-11-04";

  preferLocalBuild = true;

  src = fetchFromGitHub {
    owner = "xykt";
    repo = "HardwareQuality";
    rev = "229e1934dc4681c4e2e304f25996ad85c4025f16";
    hash = "sha256-nT+YmfQmPp3ZyxKZtuJGgoKV+6b87SwvFKUnl91Jvic=";
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
