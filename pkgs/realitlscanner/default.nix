{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "realitlscanner";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "XTLS";
    repo = "RealiTLScanner";
    tag = "v0.2.3";
    hash = "sha256-JT09ucmKuGxHFZuImIC6CnHvAGT/fPTyuOH4GZguyGA=";
  };

  vendorHash = "sha256-qNAGWAWfin8KwlMwLdEFAzGuqkOYDHcHeTXp8hk3tfw=";

  meta = {
    description = "A TLS server certificate scanner for real IP discovery";
    homepage = "https://github.com/XTLS/RealiTLScanner";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.linux;
    mainProgram = "RealiTLScanner";
  };
}
