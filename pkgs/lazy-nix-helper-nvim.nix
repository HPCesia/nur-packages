{
  lib,
  fetchFromGitHub,
  vimUtils,
  ...
}:
vimUtils.buildVimPlugin rec {
  pname = "lazy-nix-helper-nvim";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "b-src";
    repo = "lazy-nix-helper.nvim";
    rev = "v${version}";
    hash = "sha256-4DyuBMp83vM344YabL2SklQCg6xD7xGF5CvQP2q+W7A=";
  };

  meta = with lib; {
    homepage = "https://github.com/b-src/lazy-nix-helper.nvim";
    license = licenses.mit;
  };
}
