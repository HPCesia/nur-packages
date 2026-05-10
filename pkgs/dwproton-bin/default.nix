# Modify From https://github.com/powerofthe69/nix-gaming-edge
{
  pkgs,
  renameInternalName ? true,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "dwproton";
  version = "11.0-1";

  src = pkgs.fetchurl {
    url = "https://dawn.wine/dawn-winery/dwproton/releases/download/dwproton-${version}/dwproton-${version}-x86_64.tar.xz";
    hash = "sha256-5RjicnGSmlXHL/eEdTY+1aTHpkt2PcLo7FFRYBHPx2s=";
  };

  nativeBuildInputs = [pkgs.xz];
  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Create the steamcompat directory
    mkdir -p $steamcompattool
    cp -r ./* $steamcompattool/

    # Modify the display name
    sed -i -r "s|\"display_name\".*|\"display_name\" \"dwproton\"|" \
      $steamcompattool/compatibilitytool.vdf

    ${pkgs.lib.optionalString renameInternalName ''
      sed -i -r 's|"dwproton-[^"]*"(\s*// Internal name)|"dwproton"\1|' $steamcompattool/compatibilitytool.vdf
    ''}

    # Create a real folder so that Steam doesn't require reselecting compatibility tool on update
    mkdir -p $out/share/

    # Create a real folder so that Steam doesn't require reselecting compatibility tool on update
    mkdir -p $out/share/steam/compatibilitytools.d/dwproton

    #Symlink the files INSIDE, not the folder itself. Oopsie
    ln -s $steamcompattool/* $out/share/steam/compatibilitytools.d/dwproton/

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Dawn Winery's custom Proton fork with fixes for various games";
    homepage = "https://dawn.wine/dawn-winery/dwproton";
    license = licenses.bsd3;
    platforms = ["x86_64-linux"];
  };
}
