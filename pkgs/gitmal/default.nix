{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "gitmal";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "antonmedv";
    repo = "gitmal";
    tag = "v1.0.2";
    hash = "sha256-RDXtB/fgyqL3b5e2BVK5si5pIcw/un3KJy1/cU0GMXo=";
  };

  vendorHash = "sha256-12kkN1rh9OWG8YIr9KyHtm1TFJQPUtSpD6ub8zokAhQ=";

  meta = {
    description = " A static page generator for repos";
    homepage = "https://github.com/antonmedv/gitmal";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
