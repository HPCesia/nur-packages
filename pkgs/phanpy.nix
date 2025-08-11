{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "phanpy";
  version = "2025.07.18.3f4b1a6";

  src = fetchFromGitHub {
    owner = "cheeaun";
    repo = "phanpy";
    tag = "${version}";
    hash = "sha256-0OkH/XojM0W2oun797sNJqFrxNqFau1P+NECxCrib20=";
  };

  npmDepsHash = "sha256-2a+5G0ENpjOvw+TuxEJrkabAB3uoQnaBQc7Nek7a/dw=";

  npmPackFlags = ["--ignore-scripts"];

  postInstall = ''
    cp -rv dist/ $out
  '';

  meta = {
    description = "A minimalistic opinionated Mastodon web client.";
    homepage = "https://phanpy.social/";
    license = lib.licenses.mit;
  };
}
